// Copyright 2020 LTMM. All rights reserved.
// Uses of this source code is governed by 'The Unlicense' that can be
// found in the LICENSE file.

import 'package:theme_package/theme_package.dart';

class BiometricPlatformException extends AppException {
  BiometricPlatformException([String message, int code]) : super(message, 'Device Platform exception', code);
}

class InconsistantState extends AppException {
  InconsistantState([String message, int code]) : super(message, 'Inconsistent State', code);
}

class NoSuchFeature extends AppException {
  NoSuchFeature([String message, int code]) : super(message, 'No Such Feature', code);
}

class PlatformError extends AppException {
  PlatformError([String message, int code]) : super(message, 'Device Platform error', code);
}

class UnknownAuthenticationStatus extends AppException {
  UnknownAuthenticationStatus([String message, int code]) : super(message, 'Unknown Authentication Status', code);
}

class UnknownBiometricDevice extends AppException {
  UnknownBiometricDevice([String message, int code]) : super(message, 'Unknown Biometric Device', code);
}
