# Content Sources & Integrity

## Quran Text
- Preferred: Tanzil.net Uthmani text (documented, widely used, clear licensing for non-commercial / attribution).
- Alternative open sources: Quran.com data dumps, King Fahd Complex published text where redistribution is permitted.
- **Rule**: Never generate or rewrite any ayah with AI. Import only verified files and keep source metadata in the database.

### Currently bundled: `assets/quran/quran-uthmani.json`
- Text: King Fahd Quran Complex (qurancomplex.gov.sa) Uthmani Hafs text, taken **unmodified** from the `ara-quranuthmanihaf` edition of github.com/fawazahmed0/quran-api. Page (604, Madani), juz and sajdah maps come from that repo's `info.json`.
- Verified at import: 6236 ayahs, per-surah ayah counts, all 604 pages present, 30 juz, 15 sajdahs, and every surah's start page. The text also matches two independent Tanzil-derived editions (ara-quranacademy, ara-qurankhaledhosn) after normalization; the only difference is a stray spacing character in one of those editions (29:8).
- Encoding note: open tanween uses U+08F0–08F2 (Arabic Extended-A). ScheherazadeNew and Amiri (bundled) contain every character used (checked).
- **TODO before public release:** confirm the King Fahd Complex terms allow redistribution inside your app and add the required attribution. This has not been verified.

## Riwayat
- Hafs an Asim: primary, always available.
- Warsh, Qalun, Shu'bah, Al-Duri: only enable when a verified distinct text dataset is present. Otherwise mark `isAvailable = false`.

## Adhkar
- Primary reference: Hisn al-Muslim (Fortress of the Muslim) – authentic collections from Qur'an & Sunnah.
- Sources must be stored per item (Bukhari, Muslim, Abu Dawud, etc.).

## Audio
- Only use providers that explicitly allow streaming / offline download for the intended use (e.g. certain open Quran audio archives).
- Never invent or hard-code unverified URLs.
- Document each reciter + riwayah availability.

## Tafsir & Translations
- Use openly licensed or publisher-permitted packs (e.g. Sahih International, various open tafsirs).
- Keep original Arabic Quran text immutable across all interface languages.
