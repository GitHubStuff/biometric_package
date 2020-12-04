import 'package:biometric_package/biometric_package.dart';
import 'package:biometric_package/cubit/biometric_sensor_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockBiometricRespository extends Mock implements BiometricRespository {
  final bool sensorsAvailable;
  final List<BiometricSensorType> sensorList;

  MockBiometricRespository({this.sensorsAvailable = false, this.sensorList});

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

class MockCubit extends MockBloc<BiometricSensorState> implements BiometricSensorCubit {}

const Duration lockout = Duration(seconds: 10);
const Duration perm = Duration(seconds: 30);
void main() {
  mainCubit();
}

void mainCubit() {
  group('Set up tests', () {
    MockBiometricRespository repo = MockBiometricRespository();
    blocTest<BiometricSensorCubit, BiometricSensorState>(
      '[blocTestsetup ${DateTime.now().toLocal()}]',
      build: () => BiometricSensorCubit(
        biometricRespository: repo,
        permLockoutDuration: perm,
        lockedOutDuration: lockout,
      ),
      act: (cubit) async => cubit.setup(timeout: Duration()),
      expect: [isA<NoBiometricsState>()],
    );
  });

  group('Set up sensors', () {
    MockBiometricRespository repo = MockBiometricRespository(sensorsAvailable: true);
    blocTest<BiometricSensorCubit, BiometricSensorState>(
      '[blocTestsetup ${DateTime.now().toLocal()}]',
      build: () => BiometricSensorCubit(
        biometricRespository: repo,
        permLockoutDuration: perm,
        lockedOutDuration: lockout,
      ),
      act: (cubit) async => cubit.setup(timeout: Duration()),
      expect: [isA<AvailabilityState>()],
    );
  });
}
