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

## Audio assets (added Nov 2026)
- **Quran recitation**: streamed from the Islamic Network CDN (cdn.islamic.network, Al Quran Cloud). Format `quran/audio/{bitrate}/{edition}/{ayahNumber}.mp3`; editions from the official audio-editions API. Needs internet.
- **Adhkar audio**: streamed from github.com/rn0x/Adhkar-json (`audio/*.mp3`, via jsDelivr with raw.githubusercontent.com fallback). **No license file in that repository** – confirm permission before public release.
- **Adhan voices (bundled, offline)**: `android/app/src/main/res/raw/adhan_*.mp3` come from github.com/Kiwifu/adhan-mp3 (a community collection of recordings; **no license stated**; original muezzins/mosques are credited by that repo's file names). Embedded cover art/tags were stripped; audio data is unmodified. **TODO before public release:** confirm redistribution rights, or replace with recordings you have permission for.
- **Reminder voices (bundled)**: `salawat_voice.mp3` ("اللهم صل وسلم على نبينا محمد") and `tasbeeh_voice.mp3` ("سبحان الله وبحمده") are the first spoken part (cut at the first pause, before the spoken repetition count) of items [1:24] and [1:17] of Adhkar-json's audio (same licensing caveat as above). They were cut by silence analysis, not by listening – **listen to both and replace if the cut is wrong.**

## Tafsir (added Nov 2026)
- Bundled offline in `assets/tafsir/`: **التفسير الميسّر**, **تفسير الجلالين**, **تفسير السعدي** (editions `ar-tafsir-muyassar`, `ar-tafsir-al-jalalayn`, `ar-tafsir-as-saadi`).
- Text via github.com/spa5k/tafsir_api (MIT license for the repository; the underlying texts come from quran.com's tafsir data). Text is **not edited**. Only change: when a book gives the same commentary to consecutive ayahs (grouped commentary, mostly As-Saadi), it is stored once and later ayahs are stored as an empty string.
- Known gaps in the source: Al-Jalalayn has no separate entry for 226 ayahs (e.g. 2:82, 2:274, 3:2, and ayah 1 of surahs 42, 84, 106, 109); the app shows a neutral note for those.
- Tafsir Ibn Kathir (also in that repo) was **not** bundled because of its size.
- **TODO before public release:** confirm the redistribution terms of the underlying tafsir texts.
