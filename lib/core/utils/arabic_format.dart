const _digits = '٠١٢٣٤٥٦٧٨٩';

String arabicDigits(String input) {
  final b = StringBuffer();
  for (final c in input.split('')) {
    final d = int.tryParse(c);
    b.write(d == null ? c : _digits[d]);
  }
  return b.toString();
}

/// 12-hour time with Arabic digits and ص/م, e.g. ٥:٣٠ م
String formatTimeAr(DateTime t) {
  final h24 = t.hour;
  final h = h24 % 12 == 0 ? 12 : h24 % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return arabicDigits('$h:$m ${h24 < 12 ? 'ص' : 'م'}');
}

const _months = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];
const _weekdays = [
  'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
];

/// e.g. الأحد ٨ نوفمبر ٢٠٢٦
String formatDateAr(DateTime d) =>
    arabicDigits('${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]} ${d.year}');
