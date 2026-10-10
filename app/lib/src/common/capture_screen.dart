import 'package:ekokelajak_core/ekokelajak_core.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'captured_photo.dart';
import 'location.dart';

/// Ilova ichidagi kamera. Galereyadan tanlash imkoni ataylab yo'q:
/// dalil aynan shu yerda va shu paytda olinishi kerak.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, required this.title, required this.hint});

  final String title;
  final String hint;

  static Future<CapturedPhoto?> open(BuildContext context, {required String title, required String hint}) =>
      Navigator.of(context).push<CapturedPhoto>(
        MaterialPageRoute(
          builder: (_) => CaptureScreen(title: title, hint: hint),
        ),
      );

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final cameras = await availableCameras();
      final back = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      final controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await controller.takePicture();
      final capturedAt = DateTime.now();
      final position = await currentPosition();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      Navigator.of(context).pop(CapturedPhoto(bytes: bytes, capturedAt: capturedAt, position: position));
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: _error != null
          ? Center(
              child: Text(
                'Kamerani ochib bo\'lmadi: ${errorText(_error!)}',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : controller == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.hint,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(child: Center(child: CameraPreview(controller))),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _busy
                      ? const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 8),
                            Text('Joylashuv aniqlanmoqda...', style: TextStyle(color: Colors.white70)),
                          ],
                        )
                      : FloatingActionButton.large(
                          onPressed: _capture,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.camera_alt, color: Colors.black),
                        ),
                ),
              ],
            ),
    );
  }
}
