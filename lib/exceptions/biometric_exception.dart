// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

/// Reasons authentication may file, but as an [exception] not an error.
enum BiometricException {
  lockedOut,
  notAvailable,
  notEnrolled,
  otherOperatingSystem,
  passcodeNotSet,
  permanentlyLockedOut,
}

enum BiometricSupport {
  BiometricsNotSupported,
  NoSensorsAvailable,
}
