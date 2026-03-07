import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

class ScanProcessing extends StatefulWidget {
  final String imagePath;
  const ScanProcessing({super.key, required this.imagePath});

  @override
  State<ScanProcessing> createState() => _ScanProcessingState();
}

class _ScanProcessingState extends State<ScanProcessing>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  bool _scanComplete = false;
  late AnimationController _lineController;
  late Animation<double> _lineAnimation;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _progress += 0.014;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _scanComplete = true;
          _lineController.stop();
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    _progressTimer?.cancel();
    super.dispose();
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

              // Title
              const Text(
                'Plant AI Scanner',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Analyzing plant health and species',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 56),

              // Image with scan frame — 245x356 from Figma
              Center(
                child: SizedBox(
                  width: 245,
                  height: 245,
                  child: Stack(
                    children: [
                      // Plant image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _scanComplete
                            ? Container(
                          width: 245,
                          height: 245,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                          ),
                        )
                            : Image.file(
                          File(widget.imagePath),
                          width: 245,
                          height: 245,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Scanning line
                      if (!_scanComplete)
                        AnimatedBuilder(
                          animation: _lineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _lineAnimation.value * 230,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      const Color(0xFF2E7D32).withOpacity(0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      // Corner borders
                      _corner(top: 0, left: 0, flipX: false, flipY: false),
                      _corner(top: 0, right: 0, flipX: true, flipY: false),
                      _corner(bottom: 0, left: 0, flipX: false, flipY: true),
                      _corner(bottom: 0, right: 0, flipX: true, flipY: true),
                    ],
                  ),
                ),
              ),

              // Hint text (only before scan completes)
              if (!_scanComplete) ...[
                const SizedBox(height: 24),
                const Text(
                  'Make sure the plant is clearly visible in the photo for best results.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                ),
              ],

              const Spacer(),

              // Progress or Success — frame height 72px from Figma
              SizedBox(
                height: 72,
                child: _scanComplete
                    ? _buildSuccessSection()
                    : _buildProgressSection(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    int percent = (_progress * 100).toInt();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Scanning in progress... $percent%',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2E7D32),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 22),
            const SizedBox(width: 6),
            const Text(
              'Scan Completed Successfully',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF2E7D32),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          "We've identified your plant species and health condition",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'See Result',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
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