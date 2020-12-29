// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:shared_preferences/shared_preferences.dart';

import '../biometric_package.dart';

class BiometricSensorEnabled {
  static const rootKey = 'com.icodeforyou.enabled.';
  static String fullName(BiometricSensorType biometricSensor) => '$rootKey${biometricSensor.name}';

  static Future<bool> getEnabled(BiometricSensorType sensor) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(fullName(sensor)) ?? false;
  }

  static Future<void> setEnabled(bool enabled, BiometricSensorType sensor) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (enabled) {
      sharedPreferences.setBool(fullName(sensor), true);
    } else {
      sharedPreferences.remove(fullName(sensor));
    }
  }
}
