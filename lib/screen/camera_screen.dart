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
  final _cameraPreviewKey = GlobalKey();
  var _isLoading = false;

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
    final cameras = await availableCameras();

    controller = CameraController(
      cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back),
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller?.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        cameraPreviewBox = _cameraPreviewKey.currentContext?.findRenderObject() as RenderBox?;
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

  void _onTakePhotoButtonPressed() async {
    if (controller == null) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final xFile = await controller!.takePicture();
    final bytes = await xFile.readAsBytes();
    final original = img.decodeImage(bytes);
    // Start process image
    var bakedImage = img.bakeOrientation(original!);
    final x = (bakedImage.width * 0.5) - (bakedImage.height * 0.5 * 0.5);
    final y = (bakedImage.height * 0.5) - (bakedImage.width * 0.5 * 0.5);
    bakedImage = img.copyCrop(bakedImage, x: x.toInt(), y: y.toInt(), width: (bakedImage.height * 0.5).toInt(), height: (bakedImage.width * 0.5).toInt());
    // End process image
    final jpg = img.encodeJpg(bakedImage);
    final directory = await getExternalStorageDirectory();
    final file = await File('${directory!.path}/kyc.jpg').writeAsBytes(jpg);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultScreen(file: file)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          child: Column(
            children: <Widget>[
              Text(
                'Identity Card',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo of your document',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CameraPreview(
                    key: _cameraPreviewKey,
                    controller!,
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: cameraPreviewBox != null ? (cameraPreviewBox!.size.height / 2) : null,
                        height: cameraPreviewBox != null ? (cameraPreviewBox!.size.width / 2) : null,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _onTakePhotoButtonPressed,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 48,
                  child: Text(
                    _isLoading ? 'Loading...' : 'Take photo',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
