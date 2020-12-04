// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

part of 'biometric_sensor_cubit.dart';

enum BiometricBuilderState {
  AuthenticatedState,
  AvailabilityState,
  BiometricallyAuthenticated,
  CancelState,
  EnableSensorState,
  NoBiometricsState,
  ExceptionState,
  InitialState,
  LockedoutState,
  PlatformError,
  TimeoutState,
}

abstract class BiometricSensorState extends Equatable {
  final BiometricBuilderState biometricSensorState;
  const BiometricSensorState(this.biometricSensorState);

  @override
  List<Object> get props => [biometricSensorState];
}
