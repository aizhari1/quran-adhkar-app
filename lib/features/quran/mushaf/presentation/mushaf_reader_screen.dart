import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/surah_metadata.dart';

class MushafReaderScreen extends ConsumerStatefulWidget {
  const MushafReaderScreen({super.key, this.initialPage = 1});
  final int initialPage;

  @override
  ConsumerState<MushafReaderScreen> createState() => _MushafReaderScreenState();
}

class _MushafReaderScreenState extends ConsumerState<MushafReaderScreen> {
  late int _currentPage;
  late PageController _pageController;
  double _fontSize = 24;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage.clamp(1, 604);
    _pageController = PageController(initialPage: _currentPage - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  SurahMeta? _surahForPage(int page) {
    SurahMeta? result;
    for (final s in allSurahs) {
      if (s.pageStart <= page) result = s;
      else break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final surah = _surahForPage(_currentPage);

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: Text(
          surah != null
              ? '${surah.nameArabic} • ص $_currentPage'
              : 'صفحة $_currentPage',
          style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_decrease),
            onPressed: () => setState(() => _fontSize = (_fontSize - 2).clamp(16, 40)),
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            onPressed: () => setState(() => _fontSize = (_fontSize + 2).clamp(16, 40)),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmark saved (local)')),
              );
            },
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
                setState(() => _currentPage = index + 1);
              },
              itemBuilder: (context, index) {
                final page = index + 1;
                final pageSurah = _surahForPage(page);
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (pageSurah != null && pageSurah.pageStart == page) ...[
                        Text(
                          pageSurah.nameArabic,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'ScheherazadeNew',
                            fontSize: 28,
                            color: AppColors.deepEmerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pageSurah.revelationType == 'Meccan' ? 'مكية' : 'مدنية',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const Divider(height: 24),
                      ],
                      Expanded(
                        child: Center(
                          child: Text(
                            'نص عثماني للصفحة $page\n\nسيتم تحميله من ملف Tanzil الموثق\nassets/quran/quran-uthmani.json\n\nلا يتم توليد أي آية بالذكاء الاصطناعي',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ScheherazadeNew',
                              fontSize: _fontSize,
                              height: 1.9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            )
                        : null,
                  ),
                  Text('$_currentPage / 604', style: const TextStyle(fontWeight: FontWeight.w600)),
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
