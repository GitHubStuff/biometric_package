// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:biometric_package/biometric_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_package/theme_package.dart';

///
/// [TEMPLATE] for creating a biometric widget for the an [App Widget Tree]
///

const Duration defaultAuthenticationDuration = const Duration(minutes: 1);

class ExampleWidget extends StatefulWidget {
  final BiometricSensorCubit biometricSensorCubit;
  ExampleWidget(this.biometricSensorCubit);

  _ExampleWidget createState() => _ExampleWidget();
}

class _ExampleWidget extends ObservingStatefulWidget<ExampleWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void afterFirstLayoutComplete(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiometricSensorCubit, BiometricSensorState>(
        cubit: widget.biometricSensorCubit,
        builder: (context, sensorState) {
          switch (sensorState.biometricSensorState) {
            case BiometricBuilderState.AuthenticatedState:
              final duration = (sensorState as AuthenticatedState).duration;
              if (duration == null) {
                //Not authenticated
              } else {
                // Report authentication duration every 1/2 second (good interval if using animation indicator)
                widget.biometricSensorCubit.reportDuration(delayDuration: Duration(milliseconds: 500));
              }
              break;
            case BiometricBuilderState.BiometricallyAuthenticated:
              // Device authenticated user
              // Report authentication duration every 1/2 second (good interval if using animation indicator)
              widget.biometricSensorCubit.reportDuration(delayDuration: Duration(milliseconds: 500));
              break;
            case BiometricBuilderState.EnableSensorState:
              final stateInfo = (sensorState as EnableSensorState);
              // If a sensor is enabled - try to authenticate with it
              if (stateInfo.enabled) widget.biometricSensorCubit.sensorAuthenticate(usingSensor: stateInfo.sensor);
              break;

            case BiometricBuilderState.AvailabilityState:
              //final _listOfSensors = (sensorState as AvailabilityState).listOfSensors;
              break;

            case BiometricBuilderState.CancelState:
              // User canceled authentication
              break;
            case BiometricBuilderState.ExceptionState:
              // Authentication failed because of an exception (biometric failure, no biometric onboarded, etc)
              break;
            case BiometricBuilderState.InitialState:
              // CRITICAL: This must be done
              // NOTE: Initial widget state - call setup of cubit with Duration of an authenticated session
              widget.biometricSensorCubit.setup(timeout: defaultAuthenticationDuration);
              return CircularProgressIndicator();
            case BiometricBuilderState.LockedoutState:
              // The device reported a lockout (short or perm)
              break;
            case BiometricBuilderState.NoBiometricsState:
              // The device does not have at least one(1) biometric device
              break;
            case BiometricBuilderState.PlatformError:
              // So error outside the sensor, or the package
              break;
            case BiometricBuilderState.TimeoutState:
              // Authenication has passed allowed time
              break;
          }

          return Container();
        });
  }
}
