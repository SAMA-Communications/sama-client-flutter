import 'package:intl/intl.dart';

String dateToTime(DateTime? date) {
  if (date == null) return '--:--';

  return DateFormat.Hm().format(date);
}
