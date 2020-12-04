// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import '../exceptions/biometric_exception.dart';
import '../sensor_types/biometric_sensor.dart';

enum BiometricRepositoryReply {
  Authentication,
  Availability,
  Error,
  Exception,
  Sensors,
}

/// Wrapper for responses from a biometric device, or information about available biometric devices (face, scan, etc)
/// NOTE: authentication the true/false if a user has been biometerically verified
/// NOTE: availablity true/full if the device has a biometric feature
/// NOTE: error typically platform level errors when attempting to use/verify a biometric feature
/// NOTE: exception see [biometric_exception.dart] for why biometric authentication may fail

class BiometricRespositoryResponse<T> {
  BiometricRepositoryReply biometricRepositoryReply;
  T data;
  BiometricException exception;

  BiometricRespositoryResponse.authentication(this.data)
      : biometricRepositoryReply = BiometricRepositoryReply.Authentication;
  BiometricRespositoryResponse.availability(this.data)
      : biometricRepositoryReply = BiometricRepositoryReply.Availability;
  BiometricRespositoryResponse.error(this.data) : biometricRepositoryReply = BiometricRepositoryReply.Error;
  BiometricRespositoryResponse.exception(this.exception)
      : biometricRepositoryReply = BiometricRepositoryReply.Exception;
  BiometricRespositoryResponse.sensors(this.data) : biometricRepositoryReply = BiometricRepositoryReply.Sensors;
}

/// A [repository] is the abstract layer between the application and the biometric hardware layer. This allows
/// for a repository to put inserted  when using a different biometic package. [local_biometric_repository.dart] is
/// used for [pub.dev local_auth: ^0.6.3+4]

abstract class BiometricRespository {
  Future<BiometricRespositoryResponse<bool>> biometericsAvailable();
  Future<BiometricRespositoryResponse<bool>> authentication(BiometricSensorType sensor);
  Future<BiometricRespositoryResponse<List<BiometricSensorType>>> sensors();
}
