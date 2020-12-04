// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

import '../preferences/biometric_sensor_enabled.dart';

enum BiometricSensorType {
  faceId,
  fingerprint,
  irisScan,
}

extension BiometricSensorExtension on BiometricSensorType {
  /// The [state] information for a sensor is stored here and on-device, because on-device is an async task
  /// a local/sync access is needed. The values are defined bye [setup()] which [must be] called in the [cubit]
  /// when the hardware query for the [list of sensors] is returned. This is a [critical] part of mapping from
  /// the [hardware layer].
  static Map<BiometricSensorType, bool> states = Map();

  Future<void> setup() async {
    final state = await _getEnabledState();
    states[this] = state;
  }

  bool get isEnabled {
    final bool result = states[this];
    if (result == null) throw FlutterError('Invalid state $this enable state not set');
    return result;
  }

  String get name => EnumToString.convertToString(this);

  Future<bool> _getEnabledState() async {
    return await BiometricSensorEnabled.getEnabled(this);
  }

  Future<void> setEnabledState(bool state) async {
    states[this] = state ?? false;
    await BiometricSensorEnabled.setEnabled(state ?? false, this);
  }

  // ignore: missing_return
  ImageIcon imageIcon({double size = 48.0}) {
    switch (this) {
      case BiometricSensorType.faceId:
        return ImageIcon(AssetImage('images/faceid.png', package: 'biometric_package'), size: size);
      case BiometricSensorType.fingerprint:
        return ImageIcon(AssetImage('images/fingerprint.png', package: 'biometric_package'), size: size);
      case BiometricSensorType.irisScan:
        return ImageIcon(AssetImage('images/iris.png', package: 'biometric_widget'), size: size);
    }
  }
}
