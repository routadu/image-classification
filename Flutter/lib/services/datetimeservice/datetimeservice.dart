import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeService {
  DateFormat? _dateFormatter;
  DateFormat? _shortDateFormatter;
  DateFormat? _timeFormatter;
  DateFormat? _shortTimeFormatter;
  DateFormat? _dateTimeFormatter;

  void init() {
    _dateFormatter = DateFormat("d-MMMM-y");
    _shortDateFormatter = DateFormat("d/M");
    _timeFormatter = DateFormat("h:mm a");
    _shortTimeFormatter = DateFormat("h:mm a");
    _dateTimeFormatter = DateFormat("d-MMMM-y h:mm a");
  }

  dynamic currentDateTime({bool inString = true}) {
    if (inString) {
      return _dateTimeFormatter?.format(DateTime.now());
    } else {
      return DateTime.now();
    }
  }

  String? dateToString(DateTime dateTime) {
    if (dateTime == null) return '';
    return _dateFormatter?.format(dateTime);
  }

  String? timeToString(TimeOfDay timeOfDay) {
    if (timeOfDay == null) return '';
    final DateTime now = DateTime.now();
    return _timeFormatter?.format(DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    ));
  }

  String? dateTimeToString(DateTime dateTime) {
    if (dateTime != null) {
      return _dateTimeFormatter?.format(dateTime);
    } else {
      return null;
    }
  }

  String? dateTimeAndTimeOfDayToFormattedString(
      DateTime dateTime, TimeOfDay timeOfDay) {
    final DateTime now = dateTime;
    return _dateTimeFormatter?.format(DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    ));
  }

  String? extractDate(String formattedString) {
    return _dateFormatter?.format(parseDate(formattedString) ?? DateTime.now());
  }

  String? extractTime(String formattedString) {
    final DateTime? dateTime = _dateTimeFormatter?.parse(formattedString);
    return _timeFormatter?.format(dateTime ?? DateTime.now());
  }

  DateTime? parseDate(String? time) {
    if (time == null) return DateTime.now();
    return _dateFormatter?.parse(time);
  }

  TimeOfDay parseTime(String? time) {
    if (time == null) return TimeOfDay.now();
    final DateTime? _temp = _timeFormatter?.parse(time);
    return TimeOfDay(
        hour: _temp != null ? _temp.hour : 4,
        minute: _temp != null ? _temp.minute : 4);
  }

  DateTime? parseDateAndTime(String time) {
    try {
      return _dateTimeFormatter?.parse(time);
    } catch (e) {
      return null;
    }
  }

  String? shortDateTimeToString(DateTime dateTime) {
    if (dateTime == null) return '';
    return _shortDateFormatter?.format(dateTime);
  }

  String? shortTimeOfDayToString(TimeOfDay timeOfDay) {
    final DateTime now = DateTime.now();
    return _shortTimeFormatter?.format(DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    ));
  }
}
