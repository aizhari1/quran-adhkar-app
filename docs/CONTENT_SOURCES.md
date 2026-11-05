# Content Sources & Integrity

## Quran Text
- Preferred: Tanzil.net Uthmani text (documented, widely used, clear licensing for non-commercial / attribution).
- Alternative open sources: Quran.com data dumps, King Fahd Complex published text where redistribution is permitted.
- **Rule**: Never generate or rewrite any ayah with AI. Import only verified files and keep source metadata in the database.

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
