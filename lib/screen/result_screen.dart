import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kyc/screen/home_screen.dart';
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
                'Your KYC Document',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.black12,
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
