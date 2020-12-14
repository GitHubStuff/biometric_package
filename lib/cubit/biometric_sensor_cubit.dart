// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:theme_package/theme_package.dart';

import '../exceptions/biometric_exception.dart';
import '../preferences/authentication_time.dart';
import '../preferences/lockout_time.dart';
import '../repository/biometric_respository.dart';
import '../sensor_types/biometric_sensor.dart';

part 'biometric_sensor_state.dart';
part 'biometric_sensor_states.dart';

// const Duration lockedOutDuration = const Duration(seconds: 45);
// const Duration permLockoutDuration = const Duration(minutes: 5);

/// Any [cubits] for different sensor packages needs to implement this class so that
/// widgets that impact state (eg: enable/disable biometric sensor) [see: sensor_widget.dart]
/// have a shared/common abstraction to the [repository] layer.

abstract class BiometricCubit {
  void setSensorEnabled({@required BiometricSensorType sensor, @required bool enabled});
}

/// The [BLoC] layer of that responds to [events] and [emits state] through the [respository] interface
/// of the [biometric sensor(s)]
class BiometricSensorCubit extends Cubit<BiometricSensorState> implements BiometricCubit {
  final BiometricRespository biometricRespository;
  bool _reporting = false;
  Duration _timeout;
  final Duration _lockedOutDuration;
  final Duration _permLockoutDuration;

  BiometricSensorCubit(
      {@required this.biometricRespository,
      @required Duration lockedOutDuration,
      @required Duration permLockoutDuration})
      : this._lockedOutDuration = lockedOutDuration,
        this._permLockoutDuration = permLockoutDuration,
        super(InitialState());

  void cancelAuthentication() async {
    _reporting = false;
    final duration = await AuthenticationTime.duration();
    if (duration == null) return;
    _clearAuthenticationTime();
    emit(CancelState(duration));
  }

  void reportDuration({Duration delayDuration}) async {
    Duration currentLockoutDuration = await LockoutTime.duration();
    if (currentLockoutDuration != null) {
      if (currentLockoutDuration.isNegative) {
        _reportLockout();
        return;
      }
      await LockoutTime.set(null);
    }

    final durationOfCurrentAuthentication = await AuthenticationTime.duration();
    if (durationOfCurrentAuthentication == null) {
      _clearAuthenticationTime();
    } else if (durationOfCurrentAuthentication.inMilliseconds >= _timeout.inMilliseconds) {
      _clearAuthenticationTime();
      emit(TimeoutState(durationOfCurrentAuthentication));
    } else {
      Future.delayed(delayDuration ?? Duration(), () {
        if (_reporting) emit(AuthenticatedState(durationOfCurrentAuthentication));
      });
    }
  }

  /// The [usingSensor] parameter is [not used] as currently only one(1) biometric sensor is expected to
  /// exist on a device, but for [future proffing] when multiple sensors are an option, this parmeter is provided
  void sensorAuthenticate({@required BiometricSensorType usingSensor}) async {
    Duration lockoutDuration = await LockoutTime.duration();
    if (lockoutDuration != null) {
      if (lockoutDuration.isNegative) {
        _reportLockout();
        return;
      }
      await LockoutTime.set(null);
    }
    DateTime elapsedTimeSinceAuthenticated = await AuthenticationTime.get();
    final duration = await AuthenticationTime.duration();
    if (elapsedTimeSinceAuthenticated != null) {
      if (duration.inMilliseconds >= _timeout.inMilliseconds) {
        _clearAuthenticationTime();
      } else {
        reportDuration(delayDuration: null);
        return;
      }
    }
    try {
      BiometricRespositoryResponse<bool> response = await biometricRespository.authentication(usingSensor);
      if (response.biometricRepositoryReply == BiometricRepositoryReply.Authentication) {
        bool isAuthenticated = response.data;
        if (isAuthenticated) {
          _reporting = true;
          await AuthenticationTime.set(DateTime.now().toUtc());
          emit(BiometricallyAuthenticated());
        } else {
          _clearAuthenticationTime();
          emit(AuthenticatedState(null));
        }
      } else if (response.biometricRepositoryReply == BiometricRepositoryReply.Exception) {
        _clearAuthenticationTime();
        if (response.exception == BiometricException.lockedOut) {
          DateTime lockedUntil = DateTime.now().toUtc().add(_lockedOutDuration);
          await LockoutTime.set(lockedUntil);
          emit(LockedoutState(response.exception, _lockedOutDuration));
          return;
        }
        if (response.exception == BiometricException.permanentlyLockedOut) {
          DateTime lockedUntil = DateTime.now().toUtc().add(_permLockoutDuration);
          await LockoutTime.set(lockedUntil);
          emit(LockedoutState(response.exception, _permLockoutDuration));
          return;
        }
        emit(ExceptionState(response.exception));
      } else {
        throw AppException('Can not process authentication ${response.biometricRepositoryReply}', 112);
      }
    } catch (error) {
      _clearAuthenticationTime();
      emit(PlatformError(error));
    }
  }

  /// Set sensor use enabled/disabled
  void setSensorEnabled({@required BiometricSensorType sensor, @required bool enabled}) async {
    _reporting = false;
    await sensor.setEnabledState(enabled);
    _reporting = true;
    emit(EnableSensorState(sensor, enabled));
  }

  void setup({@required Duration timeout}) async {
    _timeout = timeout ?? Duration();
    _reporting = false;
    try {
      BiometricRespositoryResponse<bool> availability = await biometricRespository.biometericsAvailable();
      if ((availability.data) == false) {
        emit(NoBiometricsState(BiometricSupport.BiometricsNotSupported));
        return;
      }
      BiometricRespositoryResponse<List<BiometricSensorType>> response = await biometricRespository.sensors();
      List<BiometricSensorType> sensors = response.data;

      /// NOTE: this is critical as information about sensors my be set here as they are needed to resolve/inform
      /// state changes. If this [is not done] the app [will crash]
      for (BiometricSensorType sensor in sensors) {
        await sensor.setup();
      }
      _reporting = sensors.isNotEmpty;
      emit(_reporting ? AvailabilityState(sensors) : NoBiometricsState(BiometricSupport.NoSensorsAvailable));
    } catch (error) {
      _clearAuthenticationTime();
      emit(PlatformError(error));
    }
  }

  void _clearAuthenticationTime() async {
    _reporting = false;
    await AuthenticationTime.set(null);
  }

  void _reportLockout() async {
    Duration lockoutDuration = await LockoutTime.duration();
    _clearAuthenticationTime();
    final lockoutReason = lockoutDuration.abs().inMilliseconds > _lockedOutDuration.inMilliseconds
        ? BiometricException.permanentlyLockedOut
        : BiometricException.lockedOut;
    emit(LockedoutState(lockoutReason, null));
  }
}
