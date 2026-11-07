import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/settings_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _currentPage = (widget.initialPage ?? 1).clamp(1, 604).toInt();
    _pageController = PageController(initialPage: _currentPage - 1);
    if (widget.initialPage == null) _resumeLastPage();
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
    final surah = surahForPage(_currentPage);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          '${surah.nameArabic} • ص $_currentPage',
          style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
        ),
        actions: [
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
              'صفحة $_currentPage من 604',
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
              },
              itemBuilder: (context, index) => _MushafPage(
                key: ValueKey('mushaf-page-${index + 1}'),
                page: index + 1,
                repo: repo,
                fontSize: fontSize,
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
                  Text('$_currentPage / 604',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
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
  });

  final int page;
  final QuranRepository repo;
  final double fontSize;

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
      color: AppColors.textPrimary,
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
      spans.add(TextSpan(text: ayah.textUthmani));
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
                  color: AppColors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
