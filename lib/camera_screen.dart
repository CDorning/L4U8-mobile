import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'main.dart'; // To get the global 'cameras' list

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    if (cameras.isEmpty) {
      // Handle case where no cameras are available
      return;
    }
    _controller = CameraController(
      cameras.first, // Use the first available camera (usually the back camera)
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      setState(() {
        _capturedImage = image;
      });
    } catch (e) {
      print(e);
    }
  }

  // ESSENTIAL FEATURE 3: Send email with photo attachment
  Future<void> _sendEmail() async {
    if (_capturedImage == null) return;

    final Email email = Email(
      body: 'Dear CEA,\n\nPlease let me know if the item in the attached photo is recyclable.\n\nThank you.',
      subject: 'Recycling Query from Mobile App',
      recipients: ['recycling@centrala.cea.com'],
      attachmentPaths: [_capturedImage!.path],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app.')),
      );
    }
  }

  Widget _buildCameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_controller);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildImagePreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Image.file(File(_capturedImage!.path))),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retake'),
              onPressed: () => setState(() => _capturedImage = null),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Send to CEA'),
              onPressed: _sendEmail,
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_capturedImage == null ? 'Take a Photo' : 'Confirm Photo'),
      ),
      body: cameras.isEmpty 
        ? const Center(child: Text("No camera found on this device."))
        : _capturedImage == null ? _buildCameraPreview() : _buildImagePreview(),
      floatingActionButton: _capturedImage == null && cameras.isNotEmpty
          ? FloatingActionButton(
              onPressed: _takePicture,
              child: const Icon(Icons.camera),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}