import 'package:intl/intl.dart';

class CourseManager {
  static Map<String, dynamic>? findCurrentOrNextClass(
      List<dynamic>? courseSchedule) {
    if (courseSchedule == null)
      return null; // Ensure there's a schedule to process

    final DateTime now = DateTime.now();
    final String currentDay = DateFormat('EEEE').format(now).toLowerCase();
    Map<String, dynamic>? nextClassDetails;
    Duration? shortestTimeUntilNextClass = null;

    for (var courseData in courseSchedule) {
      var courseDataCopy = Map<String, dynamic>.from(courseData);
      final List<String> occurringDays =
          List<String>.from(courseDataCopy['occuringDays']);
      if (!occurringDays.map((d) => d.toLowerCase()).contains(currentDay))
        continue;

      final List<String> times = courseDataCopy['occuringTime'].split(' - ');
      final DateTime? courseStartTime = parseCourseTime(times[0], now);
      final DateTime? courseEndTime = parseCourseTime(times[1], now);

      if (courseStartTime == null || courseEndTime == null)
        continue; // Skip if parsing failed

      if (now.isAfter(courseStartTime) && now.isBefore(courseEndTime)) {
        // Current class found, mark as ongoing
        courseDataCopy['status'] = 'ongoing';
        return courseDataCopy;
      } else if (now.isBefore(courseStartTime)) {
        final Duration timeUntilNextClass = courseStartTime.difference(now);
        if (shortestTimeUntilNextClass == null ||
            timeUntilNextClass < shortestTimeUntilNextClass) {
          shortestTimeUntilNextClass = timeUntilNextClass;
          courseDataCopy['status'] = 'upcoming'; // Mark as upcoming
          nextClassDetails = courseDataCopy;
        }
      }
    }

    return nextClassDetails; // This will be null if there's no next class today
  }

  static DateTime? parseCourseTime(String timeStr, DateTime now) {
    try {
      final List<String> parts = timeStr.split(' ');
      final List<String> hmParts = parts[0].split(':');
      int hours = int.parse(hmParts[0]);
      final int minutes = int.parse(hmParts[1]);

      if (parts[1].toLowerCase() == 'pm' && hours != 12) {
        hours = hours + 12;
      } else if (parts[1].toLowerCase() == 'am' && hours == 12) {
        hours = 0; // Convert 12 AM to 00 hours
      }

      return DateTime(now.year, now.month, now.day, hours, minutes);
    } catch (e) {
      print('Error parsing course time: $e');
      return null; // Return null if there's an error during parsing
    }
  }
}
