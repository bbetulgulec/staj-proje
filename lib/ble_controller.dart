import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController extends GetxController {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final RxList<ScanResult> _scanResults = RxList<ScanResult>();

  Stream<List<ScanResult>> get scanResults => _scanResults.stream;

  // This Function will help users to scan nearby BLE devices and get the list of Bluetooth devices.
  Future<void> scanDevices() async {
    if (await Permission.bluetoothScan.request().isGranted) {
      if (await Permission.bluetoothConnect.request().isGranted) {
        flutterBlue.startScan(timeout: Duration(seconds: 15));

        flutterBlue.scanResults.listen((results) {
          _scanResults.addAll(results);
        });

        await Future.delayed(Duration(seconds: 15));
        flutterBlue.stopScan();
      }
    }
  }

  // This function will help user to connect to BLE devices.
  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(timeout: Duration(seconds: 15));

    device.state.listen((isConnected) {
      if (isConnected == BluetoothDeviceState.connecting) {
        print("Device connecting to: ${device.name}");
      } else if (isConnected == BluetoothDeviceState.connected) {
        print("Device connected: ${device.name}");
      } else {
        print("Device Disconnected");
      }
    });
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    await device.disconnect();
  }
}
