import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shangrila/src/http/webservice.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../apiendpoint.dart';

class ClEvent {
  Future<List<Appointment>> loadEvents(context, dynamic param) async {
    List<Appointment> appointments = [];

    String apiUrl = '$apiBase/apievents/loadEvents';
    Map<dynamic, dynamic> results = {};
    await Webservice().loadHttp(context, apiUrl,
        {'condition': jsonEncode(param)}).then((value) => results = value);
    if (kDebugMode) {
      print(results);
    }
    for (var item in results['events'] ?? []) {
      appointments.add(Appointment(
          startTime: DateTime.parse(item['from_time']),
          endTime: DateTime.parse(item['to_time']),
          subject: item['comment'],
          color: item['organ_id'].toString() == '0'
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.blue.withValues(alpha: 0.5),
          startTimeZone: '',
          endTimeZone: '',
          notes: item['id'].toString()));
    }

    appointments.sort((a, b) => a.startTime.compareTo(b.startTime));
    return appointments;
  }
}
