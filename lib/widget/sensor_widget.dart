// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../cubit/biometric_sensor_cubit.dart';
import '../sensor_types/biometric_sensor.dart';

/// Helper widget that displays a [slide-switch] for enable/disable [sensor state]

class SensorWidget extends StatelessWidget {
  final BiometricCubit biometricCubit;
  final BiometricSensorType sensor;
  final Widget trueCaption;
  final Widget falseCaption;
  final double iconSize;
  const SensorWidget({
    Key key,
    @required this.biometricCubit,
    @required this.sensor,
    @required this.trueCaption,
    @required this.falseCaption,
    this.iconSize = 32.0,
  })  : assert(biometricCubit != null),
        assert(sensor != null),
        assert(trueCaption != null),
        assert(falseCaption != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentState = sensor.isEnabled;
    final toggleSwitch = SwitchListTile(
      title: currentState ? trueCaption : falseCaption,
      value: currentState,
      onChanged: (value) => biometricCubit.setSensorEnabled(enabled: value, sensor: sensor),
      secondary: sensor.imageIcon(size: iconSize ?? 32.0),
    );
    return toggleSwitch;
  }
}
