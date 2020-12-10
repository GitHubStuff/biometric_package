// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import '../preferences/most_recent_authenication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

import '../exceptions/app_exceptions.dart';
import '../exceptions/biometric_exception.dart';
import '../sensor_types/biometric_sensor.dart';
import 'biometric_respository.dart';

part 'local_biometric_type.dart';

/// This [repository] is for use with the [pub.dev local_auth] package.
class LocalBiometricRepository implements BiometricRespository {
  final String fingerPrintPrompt;
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  final AndroidAuthMessages androidAuthMessages;
  final IOSAuthMessages iosAuthMessages;

  LocalBiometricRepository({
    @required this.fingerPrintPrompt,
    this.androidAuthMessages = const AndroidAuthMessages(),
    this.iosAuthMessages = const IOSAuthMessages(),
  }) : assert(fingerPrintPrompt != null && fingerPrintPrompt.isNotEmpty);

  Future<BiometricRespositoryResponse<bool>> authentication(BiometricSensorType sensor) async {
    try {
      final bool authenticated = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: fingerPrintPrompt,
        iOSAuthStrings: iosAuthMessages,
        androidAuthStrings: androidAuthMessages,
        useErrorDialogs: true,
        stickyAuth: true,
      );
      if (authenticated) MostRecentAuthenication.set(DateTime.now());
      return BiometricRespositoryResponse<bool>.authentication(authenticated);
    } on PlatformError catch (err) {
      throw BiometricRespositoryResponse.error(err);
    } on PlatformException catch (exception) {
      switch (exception.code) {
        case auth_error.lockedOut:
          return BiometricRespositoryResponse.exception(BiometricException.lockedOut);
        case auth_error.notAvailable:
          MostRecentAuthenication.set(null);
          return BiometricRespositoryResponse.exception(BiometricException.notAvailable);
        case auth_error.notEnrolled:
          MostRecentAuthenication.set(null);
          return BiometricRespositoryResponse.exception(BiometricException.notEnrolled);
        case auth_error.otherOperatingSystem:
          return BiometricRespositoryResponse.exception(BiometricException.otherOperatingSystem);
        case auth_error.passcodeNotSet:
          MostRecentAuthenication.set(null);
          return BiometricRespositoryResponse.exception(BiometricException.passcodeNotSet);
        case auth_error.permanentlyLockedOut:
          return BiometricRespositoryResponse.exception(BiometricException.permanentlyLockedOut);
        default:
          throw BiometricPlatformException('Unhandled PlatformException "${exception.code}"', 108);
      }
    }
  }

  @override
  Future<BiometricRespositoryResponse<bool>> biometericsAvailable() async {
    try {
      final biometricsAvailble = await _localAuthentication.canCheckBiometrics;
      return BiometricRespositoryResponse<bool>.availability(biometricsAvailble);
    } on PlatformError catch (err) {
      throw BiometricRespositoryResponse.error(err);
    }
  }

  Future<BiometricRespositoryResponse<List<BiometricSensorType>>> sensors() async {
    @override
    final List<BiometricSensorType> biometricDevices = List();
    try {
      List<BiometricType> availableBiometerics = await _localAuthentication.getAvailableBiometrics();
      availableBiometerics.forEach((type) => biometricDevices.add(type.biometricSensor));
      return BiometricRespositoryResponse<List<BiometricSensorType>>.sensors(biometricDevices);
    } on PlatformException catch (err) {
      throw PlatformError(err.message.toString(), 105);
    }
  }
}
