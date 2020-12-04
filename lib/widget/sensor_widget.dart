// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../cubit/biometric_sensor_cubit.dart';
import '../sensor_types/biometric_sensor.dart';

class SensorWidget extends StatelessWidget {
  final BiometricCubit biometricCubit;
  final BiometricSensorType sensor;
  final Widget trueCaption;
  final Widget falseCaption;
  const SensorWidget({
    @required this.biometricCubit,
    @required this.sensor,
    @required this.trueCaption,
    @required this.falseCaption,
  })  : assert(biometricCubit != null),
        assert(sensor != null),
        assert(trueCaption != null),
        assert(falseCaption != null);

  @override
  Widget build(BuildContext context) {
    final currentState = sensor.isEnabled;
    final toggleSwitch = SwitchListTile(
      title: currentState ? trueCaption : falseCaption,
      value: currentState,
      onChanged: (value) => biometricCubit.setSensorEnabled(enabled: value, sensor: sensor),
      secondary: sensor.imageIcon(size: 32.0),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: toggleSwitch,
    );
  }
}
