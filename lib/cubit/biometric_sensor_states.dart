// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

part of 'biometric_sensor_cubit.dart';

class AuthenticatedState extends BiometricSensorState {
  final Duration duration;
  const AuthenticatedState(this.duration) : super(BiometricBuilderState.AuthenticatedState);
  @override
  List<Object> get props => [duration, biometricSensorState];
}

class BiometricallyAuthenticated extends BiometricSensorState {
  const BiometricallyAuthenticated() : super(BiometricBuilderState.BiometricallyAuthenticated);
}

class AvailabilityState extends BiometricSensorState {
  final List<BiometricSensorType> listOfSensors;
  const AvailabilityState(this.listOfSensors) : super(BiometricBuilderState.AvailabilityState);
  @override
  List<Object> get props => [listOfSensors, biometricSensorState];
}

class LockedoutState extends BiometricSensorState {
  final BiometricException exception;
  final Duration duration;
  const LockedoutState(this.exception, this.duration) : super(BiometricBuilderState.LockedoutState);
  @override
  List<Object> get props => [exception, duration, biometricSensorState];
}

class CancelState extends BiometricSensorState {
  final Duration timeout;
  const CancelState(this.timeout) : super(BiometricBuilderState.CancelState);
  @override
  List<Object> get props => [timeout, biometricSensorState];
}

class EnableSensorState extends BiometricSensorState {
  final bool enabled;
  final BiometricSensorType sensor;
  const EnableSensorState(this.sensor, this.enabled) : super(BiometricBuilderState.EnableSensorState);
  @override
  List<Object> get props => [sensor, enabled, biometricSensorState];
}

class ExceptionState extends BiometricSensorState {
  final BiometricException biometricException;
  const ExceptionState(this.biometricException) : super(BiometricBuilderState.ExceptionState);
  @override
  List<Object> get props => [biometricException, biometricSensorState];
}

class InitialState extends BiometricSensorState {
  const InitialState() : super(BiometricBuilderState.InitialState);
}

class NoBiometricsState extends BiometricSensorState {
  final BiometricSupport biometricSupport;
  const NoBiometricsState(this.biometricSupport) : super(BiometricBuilderState.NoBiometricsState);
}

class PlatformError extends BiometricSensorState {
  final AppException platformError;
  const PlatformError(this.platformError) : super(BiometricBuilderState.PlatformError);
  @override
  List<Object> get props => [platformError, biometricSensorState];
}

class TimeoutState extends BiometricSensorState {
  final Duration timeout;
  const TimeoutState(this.timeout) : super(BiometricBuilderState.TimeoutState);
  @override
  List<Object> get props => [timeout, biometricSensorState];
}
