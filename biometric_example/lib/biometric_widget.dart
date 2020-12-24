import 'package:biometric_package/biometric_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theme_package/theme_package.dart';
import 'package:timed_wheel_widget/timed_wheel_widget.dart';

const Duration defaultAuthenticationDuration = const Duration(minutes: 1);

class BiometricWidget extends StatefulWidget {
  final BiometricRespository biometricRespository;
  BiometricWidget(this.biometricRespository);

  _BiometricWidget createState() => _BiometricWidget();
}

class _BiometricWidget extends ObservingStatefulWidget<BiometricWidget> {
  BiometricSensorCubit _biometricSensorCubit;
  List<BiometricSensorType> _listOfSensors = List();
  List<Widget> _displayWidgets = List();
  TimedWheelWidget _timedWheelWidget;

  @override
  void initState() {
    super.initState();
    _biometricSensorCubit = BiometricSensorCubit(
      biometricRespository: widget.biometricRespository,
      lockedOutDuration: Duration(seconds: 45),
      permLockoutDuration: Duration(minutes: 5),
    );
  }

  @override
  void afterFirstLayoutComplete(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiometricSensorCubit, BiometricSensorState>(
        cubit: _biometricSensorCubit,
        builder: (context, sensorState) {
          Widget message = Text('Unhandled state ${sensorState.biometricSensorState}');
          _displayWidgets = List();
          _displayWidgets.add(_loginWidget());
          switch (sensorState.biometricSensorState) {
            case BiometricBuilderState.AuthenticatedState:
              final duration = (sensorState as AuthenticatedState).duration;
              if (duration == null) {
                _displayWidgets.add(_text('Not Authenticated'));
              } else {
                final row = Row(
                  children: [
                    _timedWheelWidget ?? Container(),
                    _text('Authenticated for ${duration.inSeconds}s'),
                  ],
                );
                _displayWidgets.add(row);
                _biometricSensorCubit.reportDuration(delayDuration: Duration(milliseconds: 500));
              }
              break;
            case BiometricBuilderState.BiometricallyAuthenticated:
              Log.V('BiometricBuilderState.BiometricallyAuthenticated');
              _timedWheelWidget = TimedWheelWidget(
                completion: () {},
                duration: defaultAuthenticationDuration,
                callback: (_, __) {},
              );
              _biometricSensorCubit.reportDuration(delayDuration: Duration(milliseconds: 500));
              break;
            case BiometricBuilderState.EnableSensorState:
              final stateInfo = (sensorState as EnableSensorState);
              if (stateInfo.enabled) _biometricSensorCubit.sensorAuthenticate(usingSensor: stateInfo.sensor);
              _displayWidgets.add(_text('Sensors:'));
              break;

            case BiometricBuilderState.AvailabilityState:
              _listOfSensors = (sensorState as AvailabilityState).listOfSensors;
              break;

            case BiometricBuilderState.CancelState:
              _displayWidgets.add(message);
              break;
            case BiometricBuilderState.ExceptionState:
              _displayWidgets.add(message);
              break;
            case BiometricBuilderState.InitialState:
              _biometricSensorCubit.setup(timeout: defaultAuthenticationDuration);
              return CircularProgressIndicator();
            case BiometricBuilderState.LockedoutState:
            case BiometricBuilderState.NoBiometricsState:
            case BiometricBuilderState.PlatformError:
              _displayWidgets.add(message);
              break;
            case BiometricBuilderState.TimeoutState:
              _timedWheelWidget = null;
              break;
          }

          _displayWidgets.addAll(_sensorList(_listOfSensors));
          return Column(
            children: _displayWidgets,
          );
        });
  }

  Widget _text(String content) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 22.0),
      ),
    );
  }

  List<Widget> _sensorList(List<BiometricSensorType> sensors) {
    final column = List<Widget>();
    sensors?.forEach((sensor) => column.add(
          SensorWidget(
            biometricCubit: _biometricSensorCubit,
            sensor: sensor,
            trueCaption: _text('Disable ${sensor.name}'),
            falseCaption: _text('Enable ${sensor.name}'),
          ),
        ));
    return column;
  }

  Widget _loginWidget() {
    return RaisedButton(
      child: _text('Login'),
      onPressed: () => _biometricSensorCubit.sensorAuthenticate(usingSensor: null),
    );
  }
}
