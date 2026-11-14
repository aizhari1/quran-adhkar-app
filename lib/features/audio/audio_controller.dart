import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../quran/data/quran_repository.dart' show AyahData;
import 'audio_sources.dart';

enum AudioMode { none, quran, adhkar }

class AudioState {
  final AudioMode mode;
  final String reciterId;
  final bool isPlaying;
  final bool isLoading;

  /// Quran: "surah:ayah". Adhkar: "a:category:item".
  final String? currentKey;
  final String? error;

  const AudioState({
    this.mode = AudioMode.none,
    this.reciterId = kDefaultReciterId,
    this.isPlaying = false,
    this.isLoading = false,
    this.currentKey,
    this.error,
  });

  bool get quranActive => mode == AudioMode.quran;
}

/// One shared player for Quran recitation and adhkar audio, so two sounds
/// never overlap.
class AudioController extends StateNotifier<AudioState> {
  AudioController() : super(const AudioState()) {
    _loadReciter();
    _stateSub = _player.playerStateStream.listen(_onPlayerState);
    _indexSub = _player.currentIndexStream.listen(_onIndex);
  }

  static const _reciterPrefKey = 'quran_reciter';

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<int?>? _indexSub;
  final StreamController<void> _completed = StreamController<void>.broadcast();
  final Map<String, int> _bitrateCache = {};
  List<AyahData> _queue = const <AyahData>[];

  /// Fires when a Quran queue (a page) finished playing by itself.
  Stream<void> get completed => _completed.stream;

  Future<void> _loadReciter() async {
    try {
      final p = await SharedPreferences.getInstance();
      final id = p.getString(_reciterPrefKey);
      if (id != null && kReciters.any((r) => r.id == id) && mounted) {
        state = _copy(reciterId: id);
      }
    } catch (_) {}
  }

  AudioState _copy({
    AudioMode? mode,
    String? reciterId,
    bool? isPlaying,
    bool? isLoading,
    String? currentKey,
    bool clearKey = false,
    String? error,
    bool clearError = false,
  }) {
    return AudioState(
      mode: mode ?? state.mode,
      reciterId: reciterId ?? state.reciterId,
      isPlaying: isPlaying ?? state.isPlaying,
      isLoading: isLoading ?? state.isLoading,
      currentKey: clearKey ? null : (currentKey ?? state.currentKey),
      error: clearError ? null : (error ?? state.error),
    );
  }

  void _onPlayerState(PlayerState s) {
    if (!mounted) return;
    final loading = s.processingState == ProcessingState.loading ||
        s.processingState == ProcessingState.buffering;
    if (s.processingState == ProcessingState.completed) {
      final wasQuran = state.mode == AudioMode.quran;
      _queue = const <AyahData>[];
      _player.stop();
      state = _copy(
        mode: AudioMode.none,
        isPlaying: false,
        isLoading: false,
        clearKey: true,
      );
      if (wasQuran) _completed.add(null);
      return;
    }
    state = _copy(isPlaying: s.playing, isLoading: loading && state.mode != AudioMode.none);
  }

  void _onIndex(int? i) {
    if (!mounted || state.mode != AudioMode.quran) return;
    if (i == null || i < 0 || i >= _queue.length) return;
    final a = _queue[i];
    state = _copy(currentKey: '${a.surahNumber}:${a.ayahNumber}');
  }

  Future<bool> _exists(String url) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
      final res = await req.close().timeout(const Duration(seconds: 8));
      await res.drain<void>();
      return res.statusCode == 200 || res.statusCode == 206;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  /// Finds a bitrate this reciter is actually available in.
  Future<int?> _resolveBitrate(String reciterId) async {
    final cached = _bitrateCache[reciterId];
    if (cached != null) return cached;
    for (final br in kBitrates) {
      if (await _exists(ayahAudioUrl(br, reciterId, 1, 1))) {
        _bitrateCache[reciterId] = br;
        return br;
      }
    }
    return null;
  }

  Future<void> setReciter(String id) async {
    if (!kReciters.any((r) => r.id == id)) return;
    if (state.mode == AudioMode.quran) await stop();
    state = _copy(reciterId: id);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_reciterPrefKey, id);
    } catch (_) {}
  }

  /// Plays the given ayahs (normally one Mushaf page) one after another.
  Future<void> playAyahs(List<AyahData> ayahs, {int startIndex = 0}) async {
    if (ayahs.isEmpty) return;
    final reciter = state.reciterId;
    state = _copy(
      mode: AudioMode.quran,
      isLoading: true,
      isPlaying: false,
      clearError: true,
      clearKey: true,
    );
    try {
      final bitrate = await _resolveBitrate(reciter);
      if (bitrate == null) throw StateError('reciter unreachable');
      _queue = ayahs;
      final sources = ayahs
          .map((a) => AudioSource.uri(Uri.parse(
              ayahAudioUrl(bitrate, reciter, a.surahNumber, a.ayahNumber))))
          .toList();
      await _player.setAudioSource(
        ConcatenatingAudioSource(children: sources),
        initialIndex: startIndex,
      );
      final first = ayahs[startIndex];
      state = _copy(currentKey: '${first.surahNumber}:${first.ayahNumber}');
      unawaited(_player.play().catchError((Object e) {
        debugPrint('play error: $e');
      }));
    } catch (e) {
      debugPrint('playAyahs failed: $e');
      _queue = const <AyahData>[];
      state = _copy(
        mode: AudioMode.none,
        isLoading: false,
        isPlaying: false,
        clearKey: true,
        error: 'تعذر تشغيل التلاوة. تأكد من اتصال الإنترنت.',
      );
    }
  }

  /// Play / pause for a page. Starts the page if nothing is playing.
  Future<void> togglePage(List<AyahData> pageAyahs) async {
    if (state.mode == AudioMode.quran) {
      if (_player.playing) {
        await _player.pause();
      } else if (_player.processingState != ProcessingState.idle) {
        unawaited(_player.play());
      } else {
        await playAyahs(pageAyahs);
      }
      return;
    }
    await playAyahs(pageAyahs);
  }

  /// Plays one adhkar audio file; tries each URL until one works.
  Future<void> playAdhkar(String key, List<String> urls) async {
    if (state.mode == AudioMode.adhkar &&
        state.currentKey == key &&
        _player.playing) {
      await stop();
      return;
    }
    _queue = const <AyahData>[];
    state = _copy(
      mode: AudioMode.adhkar,
      isLoading: true,
      isPlaying: false,
      currentKey: key,
      clearError: true,
    );
    for (final url in urls) {
      try {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
        unawaited(_player.play().catchError((Object e) {
          debugPrint('play error: $e');
        }));
        return;
      } catch (e) {
        debugPrint('adhkar audio failed ($url): $e');
      }
    }
    state = _copy(
      mode: AudioMode.none,
      isLoading: false,
      isPlaying: false,
      clearKey: true,
      error: 'تعذر تشغيل الصوت. تأكد من اتصال الإنترنت.',
    );
  }

  Future<void> stop() async {
    _queue = const <AyahData>[];
    try {
      await _player.stop();
    } catch (_) {}
    if (mounted) {
      state = _copy(
        mode: AudioMode.none,
        isPlaying: false,
        isLoading: false,
        clearKey: true,
      );
    }
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _indexSub?.cancel();
    _completed.close();
    _player.dispose();
    super.dispose();
  }
}

final audioControllerProvider =
    StateNotifierProvider<AudioController, AudioState>((ref) {
  return AudioController();
});
