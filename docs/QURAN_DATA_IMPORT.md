# Quran Data Import Guide

## Critical Rule
**Never generate or rewrite Quran verses with AI.**
Only import verified Uthmani text from documented open sources.

## Recommended Source: Tanzil.net

1. Go to https://tanzil.net/download/
2. Download **Uthmani** text (simple or with diacritics as needed).
3. Preferred format: JSON or XML with structure:
   - surah number
   - ayah number
   - text

4. Place the file at:
   `assets/quran/quran-uthmani.json`

## Expected JSON shape (example)

```json
[
  {"sura": 1, "aya": 1, "text": "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"},
  {"sura": 1, "aya": 2, "text": "ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ"}
]
```

## Import Process (in app)

1. On first launch, check if `Ayahs` table is empty.
2. If empty, read `assets/quran/quran-uthmani.json`.
3. Insert into Drift `Ayahs` table with correct page/juz/hizb mapping.
4. Seed `Surahs` from `lib/features/quran/data/surah_metadata.dart`.
5. Store source metadata in `Riwayat` (Hafs an Asim).

## Page / Juz / Hizb Mapping

Use a verified Madani Mushaf mapping table (604 pages).
Do not invent page breaks.

## License

Respect Tanzil license (typically attribution + non-distortion of text).
Document the exact version and download date in the app About screen.
