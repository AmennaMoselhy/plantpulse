import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'scan_processing.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanProcessing(imagePath: image.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 68),

              // Title + Subtitle
              const Text(
                'Scan Your Plant!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start Scan or upload a plant image to detect\nany disease instantly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // Scan Frame
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.local_florist,
                            size: 140,
                            color: Colors.green.shade400,
                          ),
                        ),
                        _corner(top: 0, left: 0, flipX: false, flipY: false),
                        _corner(top: 0, right: 0, flipX: true, flipY: false),
                        _corner(bottom: 0, left: 0, flipX: false, flipY: true),
                        _corner(bottom: 0, right: 0, flipX: true, flipY: true),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                      label: const Text(
                        'Start Scan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image_outlined, color: Color(0xFF2E7D32), size: 20),
                      label: const Text(
                        'Upload From Gallery',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corner({double? top, double? bottom, double? left, double? right, required bool flipX, required bool flipY}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Transform.scale(
        scaleX: flipX ? -1 : 1,
        scaleY: flipY ? -1 : 1,
        child: CustomPaint(size: const Size(40, 40), painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.5)
        ..lineTo(0, 10)
        ..quadraticBezierTo(0, 0, 10, 0)
        ..lineTo(size.width * 0.5, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}