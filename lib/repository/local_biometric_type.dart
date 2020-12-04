// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

part of 'local_biometric_repository.dart';

/// This provides a [mapping] of [pub.dev local_auth] values to types used in the rest of this package.
/// The mapping allows for [abstraction] of values returned by a specific hardware/sensor package and
/// a more generic use.
extension _BiometricType on BiometricType {
  BiometricSensorType get biometricSensor {
    switch (this) {
      case BiometricType.face:
        return BiometricSensorType.faceId;
      case BiometricType.fingerprint:
        return BiometricSensorType.fingerprint;
      case BiometricType.iris:
        return BiometricSensorType.irisScan;
    }
    throw NoSuchFeature('No setting for $this', 130);
  }
}
