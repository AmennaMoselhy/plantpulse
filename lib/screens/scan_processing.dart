import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'recent_scan.dart';
import 'result_page.dart';
import 'package:PlantPulse/app_navigator.dart';
import 'package:PlantPulse/widgets/scan_progress_sections.dart';

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
  AnimationController? _lineController;
  Animation<double>? _lineAnimation;
  Timer? _progressTimer;
  bool _resultSaved = false;
  String? _savedStatus;
  bool _imageLoadFailed = false;
  late Future<bool> _imageExistsFuture;
  late double _imgW;
  late double _imgH;
  static const double _borderOffset = 22;

  ScanApiResult? _apiResult;
  bool _apiDone = false;
  String? _apiError;
  bool _isNetworkError = false;

  @override
  void initState() {
    super.initState();
    _imageExistsFuture = File(widget.imagePath).exists();
    _startAnimation();
    _callScanApi();
  }

  void _startAnimation() {
    _lineController?.dispose();
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _lineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _lineController!, curve: Curves.easeInOut),
    );

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        if (_progress < 0.9) {
          _progress += 0.014;
        } else if (_apiDone && _progress < 1.0) {
          _progress += 0.05;
        }

        if (_progress >= 1.0) {
          _progress = 1.0;
          _lineController?.stop();
          timer.cancel();
          if (_apiError == null) {
            _checkComplete();
          } else {
            setState(() => _scanComplete = true);
          }
        }
      });
    });
  }

  void _checkComplete() {
    if (_progress >= 1.0 && _apiDone) {
      if (mounted) setState(() => _scanComplete = true);
    }
  }

  Future<void> _callScanApi() async {
    final result = await runScanApi(widget.imagePath);

    if (!mounted) return;

    if (result.isNotLettuce) {
      _progressTimer?.cancel();
      _lineController?.stop();
      setState(() {
        _apiDone = true;
        _scanComplete = false;
        _progress = 0.0;
      });
      _showUnsupportedDialog();
      return;
    }

    if (result.error != null) {
      _progressTimer?.cancel();
      _lineController?.stop();
      setState(() {
        _apiError = result.error;
        _isNetworkError = result.isNetworkError;
        _apiDone = true;
      });
      _checkComplete();
      return;
    }

    setState(() {
      _apiResult = result;
      _apiDone = true;
    });
    _checkComplete();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _imgW = size.width * 0.38;
    _imgH = size.width * 0.355;
  }

  void _handleImageFailed() {
    if (_imageLoadFailed || !mounted) return;
    _imageLoadFailed = true;
    _progressTimer?.cancel();
    _lineController?.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
    _lineController?.dispose();
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
              WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _handleImageFailed(),
              );
              return Container(
                width: _imgW,
                height: _imgH,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              );
            },
          );
        }
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

  void _onRetry() {
    _progressTimer?.cancel();
    _progressTimer = null;
    _lineController?.stop();
    _lineController?.reset();
    setState(() {
      _apiError = null;
      _isNetworkError = false;
      _apiDone = false;
      _scanComplete = false;
      _progress = 0.0;
      _resultSaved = false;
      _savedStatus = null;
      _imageLoadFailed = false;
    });
    Future.microtask(() {
      _startAnimation();
      _callScanApi();
    });
  }

  void _onSeeResult() {
    if (_resultSaved) {
      if (!mounted) return;
      Navigator.push(
        context,
        fadeSlideRoute(
          ResultPage(
            imagePath: widget.imagePath,
            plantName: 'Lettuce',
            status: _savedStatus!,
            confidence: _apiResult?.confidence ?? '0',
            diseaseName: _apiResult?.diseaseName,
            description: _apiResult?.description,
            treatment: _apiResult?.treatment,
          ),
        ),
      );
      return;
    }

    _resultSaved = true;
    final status = _apiResult?.status ?? 'Healthy';
    _savedStatus = status;

    scansState.add(
      ScanRecord(
        imagePath: widget.imagePath,
        plantName: 'Lettuce',
        status: status,
        imageUrl: null,
        confidence: _apiResult?.confidence ?? '0',
        scanTime: DateTime.now(),
        diseaseName: _apiResult?.diseaseName,
        description: _apiResult?.description,
        treatment: _apiResult?.treatment,
      ),
    );
    saveScans();

    if (!mounted) return;
    Navigator.push(
      context,
      fadeSlideRoute(
        ResultPage(
          imagePath: widget.imagePath,
          plantName: 'Lettuce',
          status: _savedStatus!,
          imageUrl: null,
          confidence: _apiResult?.confidence ?? '0',
          diseaseName: _apiResult?.diseaseName,
          description: _apiResult?.description,
          treatment: _apiResult?.treatment,
        ),
      ),
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
                  color: Color(0xFF6A7282),
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
                      if (_lineAnimation != null)
                        AnimatedBuilder(
                          animation: _lineAnimation!,
                          builder: (context, child) {
                            return Positioned(
                              top: _lineAnimation!.value * (_imgH - 10),
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: const Color(0xFF286E1A),
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
                          'assets/border.png',
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
                    color: Color(0xFF4A4A4A),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
              const Spacer(),
              _scanComplete
                  ? ScanSuccessSection(
                apiError: _apiError,
                isNetworkError: _isNetworkError,
                onRetry: _onRetry,
                onSeeResult: _onSeeResult,
              )
                  : ScanProgressSection(progress: _progress),
              const SizedBox(height: 82),
            ],
          ),
        ),
      ),
    );
  }
}