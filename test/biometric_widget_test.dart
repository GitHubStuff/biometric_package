import 'package:biometric_package/biometric_package.dart';
import 'package:biometric_package/cubit/biometric_sensor_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

//import 'package:biometric_widget/biometric_widget.dart';
class MockAvailableSensors extends Mock implements BiometricRespository {
  final bool sensorsAvailable;
  final List<BiometricSensorType> sensorList;

  MockAvailableSensors({this.sensorsAvailable = false, this.sensorList});

  @override
  Future<BiometricRespositoryResponse<bool>> biometericsAvailable() async {
    return BiometricRespositoryResponse.availability(sensorsAvailable);
  }

  @override
  Future<BiometricRespositoryResponse<List<BiometricSensorType>>> sensors() async {
    return BiometricRespositoryResponse.sensors(sensorList ?? [BiometricSensorType.fingerprint]);
  }

  @override
  Future<BiometricRespositoryResponse<bool>> authentication(BiometricSensorType sensor) async {
    return BiometricRespositoryResponse.exception(BiometricException.lockedOut);
  }
}

const Duration lockout = Duration(seconds: 10);
const Duration perm = Duration(seconds: 30);
void main() {
  BiometricSensorCubit biometricSensorCubit;
  MockAvailableSensors mockBiometricRepo;

  setUp(() {
    mockBiometricRepo = MockAvailableSensors();
    biometricSensorCubit = BiometricSensorCubit(
      biometricRespository: mockBiometricRepo,
      permLockoutDuration: perm,
      lockedOutDuration: lockout,
    );
  });

  test('inital state', () {
    expect(biometricSensorCubit.state, InitialState());
  });

  test('No biometrics', () async {
    final expectedResponse = [NoBiometricsState(BiometricSupport.BiometricsNotSupported)];
    expectLater(biometricSensorCubit, emitsInOrder(expectedResponse));

    biometricSensorCubit.setup(timeout: Duration());
  });

  test('No Sensors available biometric', () {
    List<BiometricSensorType> sensors = List();
    mockBiometricRepo = MockAvailableSensors(sensorsAvailable: true, sensorList: sensors);
    biometricSensorCubit = BiometricSensorCubit(
      biometricRespository: mockBiometricRepo,
      permLockoutDuration: perm,
      lockedOutDuration: lockout,
    );
    final expectedResponse = [NoBiometricsState(BiometricSupport.NoSensorsAvailable)];

    biometricSensorCubit.setup(timeout: Duration());
    expectLater(biometricSensorCubit, emitsInOrder(expectedResponse));
  });

  test('Fingerprint', () {
    List<BiometricSensorType> sensors = [BiometricSensorType.fingerprint];
    List<BiometricSensorType> sensorX = [BiometricSensorType.irisScan];
    mockBiometricRepo = MockAvailableSensors(sensorsAvailable: true, sensorList: sensors);
    biometricSensorCubit = BiometricSensorCubit(
      biometricRespository: mockBiometricRepo,
      permLockoutDuration: perm,
      lockedOutDuration: lockout,
    );
    final expectedResponse = [AvailabilityState(sensorX)];

    biometricSensorCubit.setup(timeout: Duration());
    expectLater(biometricSensorCubit, emitsInOrder(expectedResponse));
  });
}
