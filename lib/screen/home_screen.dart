import 'package:flutter/material.dart';
import 'package:kyc/screen/camera_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera example'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open Camera'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
          },
        ),
      ),
    );
  }
}
