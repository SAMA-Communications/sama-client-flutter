import 'package:intl/intl.dart';

String dateToTime(DateTime? date) {
  if (date == null) return '--:--';

  return DateFormat.Hm().format(date);
}

String formatHHMMSS(int seconds) {
  int hours = (seconds / 3600).truncate();
  seconds = (seconds % 3600).truncate();
  int minutes = (seconds / 60).truncate();

  String hoursStr = (hours).toString().padLeft(2, '0');
  String minutesStr = (minutes).toString().padLeft(2, '0');
  String secondsStr = (seconds % 60).toString().padLeft(2, '0');

  if (hours == 0) {
    return '$minutesStr:$secondsStr';
  }

  return '$hoursStr:$minutesStr:$secondsStr';
}

String formatSecondsToTime(int totalSeconds) {
  Duration duration = Duration(seconds: totalSeconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitHours = twoDigits(duration.inHours);

  if (duration.inHours > 0) {
    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  } else {
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}

String formatDateToDay(DateTime date) {
  final now = DateTime.now();

  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return "Today";
  }

  final yesterday = now.subtract(const Duration(days: 1));
  if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday";
  }

  return DateFormat('EEE, MMM d').format(date);
}
