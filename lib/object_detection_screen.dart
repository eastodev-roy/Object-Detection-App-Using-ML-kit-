import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ObjectDetectionScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ObjectDetectionScreen({super.key, required this.cameras});

  @override
  State<StatefulWidget> createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  late CameraController _cameraController;
  String result = "";
  bool isCameraloaded = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameraController = CameraController(
      widget.cameras[0],
      ResolutionPreset.max,
    );
    await _cameraController.initialize();

    if (!mounted) return;

    setState(() {
      isCameraloaded = true;
    });
  }

  Future<void> _captureandDetect() async {
    try {
      final XFile imageFile = await _cameraController.takePicture();
      final File image = File(imageFile.path);
      await _processImage(image);
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _processImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final ImageLabeler labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
    final List<ImageLabel> labels = await labeler.processImage(inputImage);

    String detectedObjects = "";
    for (ImageLabel label in labels) {
      final String text = label.label;
      final double confidence = label.confidence;
      detectedObjects += "$text (${(confidence * 100).toStringAsFixed(2)}%)\n";
      //break;
    }

    labeler.close();
    setState(() => result = detectedObjects);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            isCameraloaded && _cameraController.value.isInitialized
                ? AspectRatio(
                  aspectRatio: _cameraController.value.aspectRatio,
                  child: CameraPreview(_cameraController),
                )
                : const Center(child: CircularProgressIndicator()),
            ElevatedButton(
              onPressed: _captureandDetect,
              child: const Icon(Icons.face_retouching_natural, size: 35),
            ),
            Text(result),
          ],
        ),
      ),
    );
  }
}
