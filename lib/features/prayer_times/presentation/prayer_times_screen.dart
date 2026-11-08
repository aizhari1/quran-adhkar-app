import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/arabic_format.dart';
import '../../../core/theme/app_colors.dart';
import '../../settings/presentation/settings_screen.dart';

class PrayerTimesState {
  final Coordinates coordinates;
  final CalculationMethod method;
  final Madhab madhab;
  final DateTime date;
  final PrayerTimes? times;
  final String cityName;
  final bool isLoadingLocation;
  final String? locationError;

  PrayerTimesState({
    Coordinates? coordinates,
    this.method = CalculationMethod.egyptian,
    this.madhab = Madhab.shafi,
    required this.date,
    this.times,
    this.cityName = 'القاهرة',
    this.isLoadingLocation = false,
    this.locationError,
  }) : coordinates = coordinates ?? Coordinates(30.0444, 31.2357);

  PrayerTimesState copyWith({
    Coordinates? coordinates,
    CalculationMethod? method,
    Madhab? madhab,
    DateTime? date,
    PrayerTimes? times,
    String? cityName,
    bool? isLoadingLocation,
    String? locationError,
    bool clearError = false,
  }) {
    return PrayerTimesState(
      coordinates: coordinates ?? this.coordinates,
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
      date: date ?? this.date,
      times: times ?? this.times,
      cityName: cityName ?? this.cityName,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      locationError: clearError ? null : (locationError ?? this.locationError),
    );
  }
}

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  PrayerTimesNotifier(this._settings)
      : super(PrayerTimesState(date: DateTime.now())) {
    _applySettings();
    _calculate();
  }

  final AppSettingsState _settings;

  void _applySettings() {
    final method = _mapMethod(_settings.calculationMethod);
    final madhab =
        _settings.asrMethod == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
    state = state.copyWith(method: method, madhab: madhab);
  }

  CalculationMethod _mapMethod(String key) {
    switch (key) {
      case 'muslim_world_league':
        return CalculationMethod.muslim_world_league;
      case 'karachi':
        return CalculationMethod.karachi;
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura;
      case 'north_america':
        return CalculationMethod.north_america;
      default:
        return CalculationMethod.egyptian;
    }
  }

  void _calculate() {
    final params = state.method.getParameters();
    params.madhab = state.madhab;
    final times = PrayerTimes(
      state.coordinates,
      DateComponents.from(state.date),
      params,
    );
    state = state.copyWith(times: times);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
    _calculate();
  }

  void setLocation(double lat, double lng, String city) {
    state = state.copyWith(
      coordinates: Coordinates(lat, lng),
      cityName: city,
      clearError: true,
    );
    _calculate();
  }

  Future<void> useCurrentLocation() async {
    state = state.copyWith(isLoadingLocation: true, clearError: true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationError: 'خدمة الموقع غير مفعّلة',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoadingLocation: false,
          locationError: 'لم يتم منح إذن الموقع',
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      state = state.copyWith(
        coordinates: Coordinates(pos.latitude, pos.longitude),
        cityName:
            'موقعي الحالي (${pos.latitude.toStringAsFixed(2)}, ${pos.longitude.toStringAsFixed(2)})',
        isLoadingLocation: false,
        clearError: true,
      );
      _calculate();
    } catch (e) {
      state = state.copyWith(
        isLoadingLocation: false,
        locationError: 'تعذر الحصول على الموقع',
      );
    }
  }

  /// Fajr of the following day, used as "next prayer" after Isha.
  DateTime nextDayFajr() {
    final params = state.method.getParameters();
    params.madhab = state.madhab;
    final tomorrow = state.date.add(const Duration(days: 1));
    return PrayerTimes(
      state.coordinates,
      DateComponents.from(tomorrow),
      params,
    ).fajr.toLocal();
  }

  void syncFromSettings(AppSettingsState settings) {
    final method = _mapMethod(settings.calculationMethod);
    final madhab =
        settings.asrMethod == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
    state = state.copyWith(method: method, madhab: madhab);
    _calculate();
  }
}

final prayerTimesProvider =
    StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  // read (not watch): watching would recreate the notifier on every settings
  // change and reset the user's location back to Cairo.
  final notifier = PrayerTimesNotifier(ref.read(appSettingsProvider));
  ref.listen<AppSettingsState>(appSettingsProvider, (_, next) {
    notifier.syncFromSettings(next);
  });
  return notifier;
});

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerTimesProvider);
    final notifier = ref.read(prayerTimesProvider.notifier);
    final times = state.times;
    final now = DateTime.now();

    if (times == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final prayers = [
      _PrayerInfo('Fajr', 'الفجر', times.fajr.toLocal()),
      _PrayerInfo('Sunrise', 'الشروق', times.sunrise.toLocal()),
      _PrayerInfo('Dhuhr', 'الظهر', times.dhuhr.toLocal()),
      _PrayerInfo('Asr', 'العصر', times.asr.toLocal()),
      _PrayerInfo('Maghrib', 'المغرب', times.maghrib.toLocal()),
      _PrayerInfo('Isha', 'العشاء', times.isha.toLocal()),
    ];

    _PrayerInfo? nextPrayer;
    for (final p in prayers) {
      if (p.time.isAfter(now)) {
        nextPrayer = p;
        break;
      }
    }
    // After Isha: next prayer is tomorrow's Fajr.
    nextPrayer ??= _PrayerInfo('Fajr', 'الفجر', notifier.nextDayFajr());


    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        actions: [
          if (state.isLoadingLocation)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.my_location),
              tooltip: 'استخدم موقعي',
              onPressed: () => notifier.useCurrentLocation(),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.deepEmerald,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.mutedGold),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.cityName,
                          style: const TextStyle(
                            color: AppColors.warmIvory,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDateAr(state.date),
                    style: TextStyle(
                      color: AppColors.warmIvory.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  if (state.locationError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.locationError!,
                      style: const TextStyle(
                          color: Colors.orangeAccent, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: state.isLoadingLocation
                        ? null
                        : () => notifier.useCurrentLocation(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mutedGold,
                      side: const BorderSide(color: AppColors.mutedGold),
                    ),
                    icon: const Icon(Icons.gps_fixed, size: 18),
                    label: const Text('تحديد موقعي الحالي'),
                  ),
                ],
              ),
            ),
          ),
          if (nextPrayer != null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.access_time, color: AppColors.mutedGold),
                title: Text('التالي: ${nextPrayer.nameAr}'),
                subtitle: Text(formatTimeAr(nextPrayer.time)),
                trailing: Text(
                  _countdown(nextPrayer.time, now),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepEmerald,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...prayers.map((p) {
            final isNext = nextPrayer?.name == p.name && nextPrayer?.time == p.time;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isNext
                  ? AppColors.deepEmerald.withOpacity(0.08)
                  : Colors.white,
              child: ListTile(
                title: Text(
                  p.nameAr,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.deepEmerald,
                  ),
                ),
                trailing: Text(
                  formatTimeAr(p.time),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color:
                        isNext ? AppColors.mutedGold : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          const Text(
            'طريقة الحساب والإعدادات من شاشة الإعدادات',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  String _countdown(DateTime target, DateTime now) {
    final d = target.difference(now);
    if (d.isNegative) return '';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '${h}س ${m}د';
    return '${m}د';
  }
}

class _PrayerInfo {
  final String name;
  final String nameAr;
  final DateTime time;
  const _PrayerInfo(this.name, this.nameAr, this.time);
}
