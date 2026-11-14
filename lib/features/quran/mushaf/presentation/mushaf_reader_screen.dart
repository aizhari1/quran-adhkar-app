import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../audio/audio_controller.dart';
import '../../../settings/presentation/settings_screen.dart';
import '../../../tafsir/tafsir_repository.dart';
import '../../reciters/presentation/reciters_screen.dart';
import '../../data/quran_repository.dart';
import '../../data/reading_prefs.dart';
import '../../data/surah_metadata.dart';

class MushafReaderScreen extends ConsumerStatefulWidget {
  /// [initialPage] null = resume from the last page that was read.
  const MushafReaderScreen({super.key, this.initialPage});
  final int? initialPage;

  @override
  ConsumerState<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends ConsumerState<MushafReaderScreen> {
  late int _currentPage;
  late PageController _pageController;
  StreamSubscription<void>? _completedSub;
  bool _autoAdvancing = false;
  bool _tafsirMode = false;

  @override
  void initState() {
    super.initState();
    _currentPage = (widget.initialPage ?? 1).clamp(1, 604).toInt();
    _pageController = PageController(initialPage: _currentPage - 1);
    if (widget.initialPage == null) _resumeLastPage();
    // When a page's recitation ends, turn the page and keep reciting.
    _completedSub = ref
        .read(audioControllerProvider.notifier)
        .completed
        .listen((_) => _advanceAndPlay());
  }

  Future<void> _togglePlay() async {
    final ayahs =
        await ref.read(quranRepositoryProvider).getAyahsForPage(_currentPage);
    await ref.read(audioControllerProvider.notifier).togglePage(ayahs);
  }

  Future<void> _advanceAndPlay() async {
    if (!mounted || _currentPage >= 604) return;
    _autoAdvancing = true;
    try {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } finally {
      _autoAdvancing = false;
    }
    if (!mounted) return;
    final ayahs =
        await ref.read(quranRepositoryProvider).getAyahsForPage(_currentPage);
    await ref.read(audioControllerProvider.notifier).playAyahs(ayahs);
  }

  void _pickTafsirBook() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(tafsirBookProvider);
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                for (final b in kTafsirBooks)
                  RadioListTile<String>(
                    value: b.id,
                    groupValue: selected,
                    title: Text(b.name),
                    subtitle: Text(b.description),
                    onChanged: (v) {
                      if (v == null) return;
                      ref.read(tafsirBookProvider.notifier).select(v);
                      Navigator.pop(ctx);
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _pickReciter() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: ReciterList(onSelected: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  Future<void> _resumeLastPage() async {
    final last = await ref.read(readingPrefsProvider).loadLastPage();
    if (!mounted || last == null) return;
    final page = last.clamp(1, 604).toInt();
    if (_pageController.hasClients) _pageController.jumpToPage(page - 1);
    setState(() => _currentPage = page);
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    final audio = ref.read(audioControllerProvider.notifier);
    Future.microtask(audio.stop);
    _pageController.dispose();
    super.dispose();
  }

  void _changeFontSize(double delta) {
    final current = ref.read(appSettingsProvider).quranFontSize;
    ref.read(appSettingsProvider.notifier).setFontSize(current + delta);
  }

  void _toggleBookmark() {
    final added = ref.read(bookmarksProvider.notifier).toggle(_currentPage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added
            ? 'تمت إضافة إشارة مرجعية • صفحة $_currentPage'
            : 'تم حذف الإشارة المرجعية'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(quranRepositoryProvider);
    final fontSize = ref.watch(appSettingsProvider).quranFontSize;
    final isBookmarked = ref.watch(bookmarksProvider).contains(_currentPage);
    final audio = ref.watch(audioControllerProvider);
    final tafsirBookId = ref.watch(tafsirBookProvider);
    ref.listen<AudioState>(audioControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });
    final surah = surahForPage(_currentPage);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${surah.nameArabic} • ص $_currentPage',
          style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
        ),
        actions: [
          IconButton(
            icon: Icon(_tafsirMode ? Icons.auto_stories : Icons.auto_stories_outlined),
            color: _tafsirMode ? AppColors.mutedGold : null,
            tooltip: _tafsirMode ? 'إخفاء التفسير' : 'عرض التفسير',
            onPressed: () => setState(() => _tafsirMode = !_tafsirMode),
          ),
          if (_tafsirMode)
            IconButton(
              icon: const Icon(Icons.library_books_outlined),
              tooltip: 'اختيار كتاب التفسير',
              onPressed: _pickTafsirBook,
            ),
          IconButton(
            icon: const Icon(Icons.record_voice_over_outlined),
            tooltip: 'اختيار القارئ',
            onPressed: _pickReciter,
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'تصغير الخط',
            onPressed: () => _changeFontSize(-2),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'تكبير الخط',
            onPressed: () => _changeFontSize(2),
          ),
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            color: isBookmarked ? AppColors.mutedGold : null,
            tooltip: 'إشارة مرجعية',
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.deepEmerald.withOpacity(0.05),
            child: Text(
              _tafsirMode
                  ? 'صفحة $_currentPage من 604 • ${tafsirBookById(tafsirBookId).name}'
                  : 'صفحة $_currentPage من 604',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 604,
              onPageChanged: (index) {
                final page = index + 1;
                setState(() => _currentPage = page);
                ref.read(lastReadPageProvider.notifier).set(page);
                // Swiping away while reciting stops the recitation.
                if (!_autoAdvancing && ref.read(audioControllerProvider).quranActive) {
                  ref.read(audioControllerProvider.notifier).stop();
                }
              },
              itemBuilder: (context, index) => _tafsirMode
                  ? _TafsirPage(
                      key: ValueKey('tafsir-page-${index + 1}'),
                      page: index + 1,
                      repo: repo,
                      fontSize: fontSize,
                      highlightKey: audio.quranActive ? audio.currentKey : null,
                    )
                  : _MushafPage(
                      key: ValueKey('mushaf-page-${index + 1}'),
                      page: index + 1,
                      repo: repo,
                      fontSize: fontSize,
                      highlightKey: audio.quranActive ? audio.currentKey : null,
                    ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // arrow_back / arrow_forward mirror automatically in RTL.
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            )
                        : null,
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _togglePlay,
                    icon: audio.quranActive && audio.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(audio.quranActive && audio.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded),
                    label: Text(audio.quranActive && audio.isLoading
                        ? 'جارٍ التحميل'
                        : (audio.quranActive && audio.isPlaying
                            ? 'إيقاف مؤقت'
                            : 'استماع')),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < 604
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageData {
  const _PageData(this.ayahs, this.basmala);
  final List<AyahData> ayahs;
  final String basmala;
}

class _MushafPage extends StatefulWidget {
  const _MushafPage({
    super.key,
    required this.page,
    required this.repo,
    required this.fontSize,
    this.highlightKey,
  });

  final int page;
  final QuranRepository repo;
  final double fontSize;

  /// "surah:ayah" of the ayah currently being recited, if any.
  final String? highlightKey;

  @override
  State<_MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends State<_MushafPage> {
  late Future<_PageData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_PageData> _load() async {
    final ayahs = await widget.repo.getAyahsForPage(widget.page);
    final basmala = await widget.repo.getBasmala();
    return _PageData(ayahs, basmala);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PageData>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('تعذر تحميل نص الصفحة'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => setState(() => _data = _load()),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(snapshot.data!);
      },
    );
  }

  Widget _buildContent(_PageData data) {
    final base = TextStyle(
      fontFamily: 'ScheherazadeNew',
      fontSize: widget.fontSize,
      height: 2.0,
      color: Theme.of(context).colorScheme.onSurface,
    );
    final children = <Widget>[];
    var spans = <InlineSpan>[];

    void flush() {
      if (spans.isEmpty) return;
      children.add(Text.rich(
        TextSpan(children: spans, style: base),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
      ));
      spans = <InlineSpan>[];
    }

    for (final ayah in data.ayahs) {
      if (ayah.ayahNumber == 1) {
        flush();
        final showBasmala = ayah.surahNumber != 1 && ayah.surahNumber != 9;
        children.add(_SurahHeader(
          surah: surahByNumber(ayah.surahNumber),
          basmala: showBasmala ? data.basmala : null,
          fontSize: widget.fontSize,
        ));
      }
      final isCurrent =
          widget.highlightKey == '${ayah.surahNumber}:${ayah.ayahNumber}';
      spans.add(TextSpan(
        text: ayah.textUthmani,
        style: isCurrent
            ? TextStyle(backgroundColor: AppColors.mutedGold.withOpacity(0.3))
            : null,
      ));
      spans.add(TextSpan(
        text: ' \uFD3F${toArabicDigits(ayah.ayahNumber)}\uFD3E ',
        style: TextStyle(
          color: AppColors.mutedGold,
          fontSize: widget.fontSize * 0.8,
        ),
      ));
    }
    flush();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({
    required this.surah,
    required this.basmala,
    required this.fontSize,
  });

  final SurahMeta surah;
  final String? basmala;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.deepEmerald.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mutedGold.withOpacity(0.6)),
            ),
            child: Column(
              children: [
                Text(
                  'سورة ${surah.nameArabic}',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'ScheherazadeNew',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepEmerald,
                  ),
                ),
                Text(
                  '${surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية'} • ${toArabicDigits(surah.ayahCount)} آية',
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (basmala != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                basmala!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: fontSize,
                  height: 2.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


/// Reading mode with the tafsir: each ayah followed by its tafsir.
class _TafsirPage extends ConsumerStatefulWidget {
  const _TafsirPage({
    super.key,
    required this.page,
    required this.repo,
    required this.fontSize,
    this.highlightKey,
  });

  final int page;
  final QuranRepository repo;
  final double fontSize;
  final String? highlightKey;

  @override
  ConsumerState<_TafsirPage> createState() => _TafsirPageState();
}

class _TafsirPageState extends ConsumerState<_TafsirPage> {
  late Future<_PageData> _data;

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_PageData> _load() async {
    final ayahs = await widget.repo.getAyahsForPage(widget.page);
    final basmala = await widget.repo.getBasmala();
    return _PageData(ayahs, basmala);
  }

  @override
  Widget build(BuildContext context) {
    final bookId = ref.watch(tafsirBookProvider);
    final tafsir = ref.watch(tafsirIndexProvider(bookId));
    return FutureBuilder<_PageData>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasError || tafsir.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('تعذر تحميل التفسير'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    ref.invalidate(tafsirIndexProvider(bookId));
                    setState(() => _data = _load());
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }
        final index = tafsir.valueOrNull;
        if (!snapshot.hasData || index == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildList(snapshot.data!, index);
      },
    );
  }

  Widget _buildList(_PageData data, TafsirIndex index) {
    final cs = Theme.of(context).colorScheme;
    final tafsirSize = widget.fontSize * 0.72 < 15 ? 15.0 : widget.fontSize * 0.72;
    final children = <Widget>[];

    for (final ayah in data.ayahs) {
      if (ayah.ayahNumber == 1) {
        final showBasmala = ayah.surahNumber != 1 && ayah.surahNumber != 9;
        children.add(_SurahHeader(
          surah: surahByNumber(ayah.surahNumber),
          basmala: showBasmala ? data.basmala : null,
          fontSize: widget.fontSize,
        ));
      }
      final isCurrent =
          widget.highlightKey == '${ayah.surahNumber}:${ayah.ayahNumber}';
      final text = index.textFor(ayah.surahNumber, ayah.ayahNumber);

      Widget tafsirBody;
      if (text == null) {
        tafsirBody = Text(
          'لا يتوفر نص تفسير منفصل لهذه الآية في هذا الكتاب.',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        );
      } else if (text.isEmpty) {
        tafsirBody = Text(
          'تفسير هذه الآية مذكور مع الآية السابقة.',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        );
      } else {
        tafsirBody = SelectableText(
          text,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: tafsirSize,
            height: 1.9,
            color: cs.onSurface,
          ),
        );
      }

      children.add(Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.mutedGold.withOpacity(0.18)
              : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCurrent ? AppColors.mutedGold : cs.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: ayah.textUthmani),
                  TextSpan(
                    text: ' \uFD3F${toArabicDigits(ayah.ayahNumber)}\uFD3E',
                    style: TextStyle(
                      color: AppColors.mutedGold,
                      fontSize: widget.fontSize * 0.8,
                    ),
                  ),
                ],
                style: TextStyle(
                  fontFamily: 'ScheherazadeNew',
                  fontSize: widget.fontSize,
                  height: 2.0,
                  color: cs.onSurface,
                ),
              ),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
            ),
            Divider(height: 24, color: cs.outlineVariant),
            Row(
              children: [
                Icon(Icons.auto_stories_outlined,
                    size: 16, color: cs.primary),
                const SizedBox(width: 6),
                Text(
                  'التفسير',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            tafsirBody,
          ],
        ),
      ));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
