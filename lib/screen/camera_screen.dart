import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:kyc/screen/result_screen.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final GlobalKey _widgetKey = GlobalKey();
  List<CameraDescription> _cameras = <CameraDescription>[];
  CameraController? controller;
  RenderBox? cameraPreviewBox;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    _cameras = await availableCameras();
    controller = CameraController(
      _cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller?.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        cameraPreviewBox = _widgetKey.currentContext?.findRenderObject() as RenderBox?;
      });
    });
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    CameraPreview(
                      key: _widgetKey,
                      controller!,
                      child: Container(
                        alignment: Alignment.center,
                        child: Container(
                          width: cameraPreviewBox != null ? (cameraPreviewBox!.size.height / 2) : null,
                          height: cameraPreviewBox != null ? (cameraPreviewBox!.size.width / 2) : null,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: controller != null && controller!.value.isInitialized ? onTakePictureButtonPressed : null,
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                height: 96,
                child: const Icon(
                  Icons.camera,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onTakePictureButtonPressed() async {
    if (controller == null) return;
    final xFile = await controller!.takePicture();
    if (!mounted) return;

    final bytes = await xFile.readAsBytes();
    final original = img.decodeImage(bytes);
    var bakedImage = img.bakeOrientation(original!);
    final x = (bakedImage.width * 0.5) - (bakedImage.height * 0.5 * 0.5);
    final y = (bakedImage.height * 0.5) - (bakedImage.width * 0.5 * 0.5);
    bakedImage = img.copyCrop(bakedImage, x: x.toInt(), y: y.toInt(), width: (bakedImage.height * 0.5).toInt(), height: (bakedImage.width * 0.5).toInt());
    debugPrint('width ${original.width}, height ${original.height}');
    debugPrint('width ${bakedImage.width}, height ${bakedImage.height}');
    final jpg = img.encodeJpg(bakedImage);
    final directory = await getExternalStorageDirectory();
    final file = await File('${directory!.path}/scan.jpg').writeAsBytes(jpg);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(file: file)),
    );
  }
}
