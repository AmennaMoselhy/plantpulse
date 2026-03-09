import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'greenButton.dart';
import 'dart:math';
import 'recentScan.dart';

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
  bool _resultSaved = false;
  bool _imageLoadFailed = false;
  late Future<bool> _imageExistsFuture;

  static const double _imgW = 151;
  static const double _imgH = 141;
  static const double _borderOffset = 22;

  @override
  void initState() {
    super.initState();

    _imageExistsFuture = File(widget.imagePath).exists();

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController, curve: Curves.easeInOut),
    );

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
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

  void _handleImageFailed() {
    if (_imageLoadFailed || !mounted) return;
    _imageLoadFailed = true;
    _progressTimer?.cancel();
    _lineController.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showUnsupportedDialog();
    });
  }

  void _showUnsupportedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unsupported Plant Detected',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Oops! This doesn't look like a lettuce plant",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF717171),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF399B25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lineController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  Widget _buildImage() {
    return FutureBuilder<bool>(
      future: _imageExistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: _imgW,
            height: _imgH,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return Image.file(
            File(widget.imagePath),
            width: _imgW,
            height: _imgH,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              // ✅ الصورة موجودة بس مش اتعرضتش → popup
              _handleImageFailed();
              return Container(
                width: _imgW,
                height: _imgH,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              );
            },
          );
        }

        // ✅ الصورة مش موجودة أصلاً → popup
        _handleImageFailed();
        return Container(
          width: _imgW,
          height: _imgH,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported),
        );
      },
    );
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
              const Text(
                'Plant AI Scanner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Analyzing plant health and species',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0XFF6A7282),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 72),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(_borderOffset),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _buildImage(),
                      ),
                      if (!_scanComplete)
                        AnimatedBuilder(
                          animation: _lineAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _lineAnimation.value * (_imgH - 10),
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: const Color(0XFF286E1A),
                              ),
                            );
                          },
                        ),
                      Positioned(
                        left: -_borderOffset,
                        top: -_borderOffset,
                        right: -_borderOffset,
                        bottom: -_borderOffset,
                        child: Image.asset(
                          "assets/border.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_scanComplete) ...[
                const SizedBox(height: 56),
                const Text(
                  'Make sure the plant is clearly visible in the photo for best results.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0XFF4A4A4A),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
              const Spacer(),
              _scanComplete ? _buildSuccessSection() : _buildProgressSection(),
              const SizedBox(height: 82),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    int percent = (_progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 21, left: 21),
          padding: const EdgeInsets.only(
            right: 20,
            left: 20,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0XFFEBF5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0XFFEBF5E9),
                  border: Border.all(
                    color: const Color(0XFF399B25),
                    width: 1.6,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Scanning in progress... $percent%',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0XFF4A4A4A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 6,
            backgroundColor: const Color(0XFFF5F5F5),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0XFF399B25)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.check_circle_outlined,
              color: Color(0xFF399B25),
              size: 30,
            ),
            SizedBox(width: 4),
            Text(
              'Scan Completed Successfully',
              style: TextStyle(
                fontSize: 13,
                color: Color(0XFF399B25),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.5),
        const Text(
          "We've identified your plant species and health condition",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Color(0XFF4A4A4A),
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 20),
        GreenButton(
          text: "See Result",
          onPress: () {
            if (!_resultSaved) {
              _resultSaved = true;
              final random = Random();
              final status = random.nextBool() ? 'Healthy' : 'Diseased';
              recentScans.add(
                ScanRecord(
                  imagePath: widget.imagePath,
                  plantName: 'Lettuce type',
                  status: status,
                  scanTime: DateTime.now(),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
