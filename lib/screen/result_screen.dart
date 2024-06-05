import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kyc/screen/screen.dart';
import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.file,
  });

  final File file;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    imageCache.clear();
  }

  void _onBackToHomeButtonPressed() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final directory = await getExternalStorageDirectory();
    directory?.deleteSync(recursive: true);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Your File Result',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please review the image to ensure all details are clear and legible',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.file.path),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _onBackToHomeButtonPressed,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade500,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 48,
                  child: Text(
                    _isLoading ? 'Loading...' : 'Kembali ke halaman awal',
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
