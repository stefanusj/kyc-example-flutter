import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:kyc/screen/screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final _signatureKey = GlobalKey();
  var _isLoading = false;

  SignatureController? controller;

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  Future<void> _initStateAsync() async {
    controller = SignatureController(
      penColor: Colors.black,
      penStrokeWidth: 1,
      exportBackgroundColor: Colors.transparent,
      exportPenColor: Colors.black,
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onSignatureClearButtonPressed() async {
    if (controller == null) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    controller?.clear();

    setState(() {
      _isLoading = false;
    });
  }

  void _onSignatureSaveButtonPressed() async {
    if (controller == null) return;
    if (controller!.isEmpty) return;
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final height = controller!.defaultHeight! + 16;
    final width = controller!.defaultWidth! + 16;
    final bytes = await controller!.toPngBytes(height: height, width: width);
    if (bytes == null) return;

    final original = img.decodeImage(bytes);
    final png = img.encodePng(original!);
    final directory = await getExternalStorageDirectory();
    final file = await File('${directory!.path}/signature.png').writeAsBytes(png);

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
    if (controller == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          child: Column(
            children: <Widget>[
              Text(
                'Signature',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ensure that your signature is clear and easily recognizable',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Signature(
                    key: _signatureKey,
                    controller: controller!,
                    backgroundColor: Colors.black12,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: _onSignatureClearButtonPressed,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade500),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 48,
                        child: Text(
                          _isLoading ? 'Loading...' : 'Clear',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.blue.shade500),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: _onSignatureSaveButtonPressed,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade500,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        height: 48,
                        child: Text(
                          _isLoading ? 'Loading...' : 'Save Signature',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
