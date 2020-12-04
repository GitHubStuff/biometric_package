// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

/// If [lockout exception] is singled by the sensor, a method of reporting/tracking lockout is needed
/// to control state (eg: allowing when the user can try again). For that, the DateTime, the [lockout exception]
/// occured is stored.
class LockoutTime {
  static const key = 'com.icodeforyou.lockoutTime';

  static Future<Duration> duration([DateTime forTime]) async {
    DateTime thenTime = await get();
    DateTime nowTime = forTime ?? DateTime.now().toUtc();
    return (thenTime == null) ? null : nowTime.difference(thenTime);
  }

  static Future<DateTime> get() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final String utcString = sharedPreferences.getString(key);
    return (utcString == null) ? null : DateTime.parse(utcString);
  }

  static Future<void> set(DateTime dateTime) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (dateTime == null) {
      sharedPreferences.remove(key);
      return;
    }
    final String utcString = dateTime.toUtc().toIso8601String();
    sharedPreferences.setString(key, utcString);
  }
}
