import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection_app/object_detection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(home: ObjectDetectionScreen(cameras: cameras)));
}
