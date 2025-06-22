import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  bool _cameraInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _errorMessage = 'No cameras available');
        return;
      }

      // Use back camera by default
      final camera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      setState(() {
        _initializeControllerFuture = _controller!.initialize().then((_) {
          if (mounted) setState(() => _cameraInitialized = true);
        }).catchError((e) {
          if (mounted) setState(() => _errorMessage = 'Failed to initialize camera');
        });
      });
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Camera error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131A21), //  dark blue color
      body: Column(
        children: [
          // Camera preview (top half)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: _buildCameraPreview(),
          ),

          // Bottom content area
          Expanded(
            child: Container(
              color: const Color(0xFF131A21),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera, size: 80),
                    color: Colors.white,
                    onPressed: () async {
                      if (_controller == null || !_cameraInitialized) return;

                      try {
                        final image = await _controller!.takePicture();
                        // Handle captured image
                      } catch (e) {
                        if (mounted) setState(() => _errorMessage = 'Capture failed: $e');
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tap to capture',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    if (_initializeControllerFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (_cameraInitialized && _controller != null) {
            return CameraPreview(_controller!);
          }
          return Center(
            child: Text(
              'Camera not available',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}