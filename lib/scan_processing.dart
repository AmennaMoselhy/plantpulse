import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'green_button.dart';
import 'recent_scan.dart';
import 'package:flutter/services.dart';
import 'result_page.dart';
import 'user_state.dart';
import 'package:vibration/vibration.dart';
import 'app_navigator.dart';

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

  String? _apiStatus;
  String? _apiConfidence;
  String? _apiDiseaseName;
  String? _apiDescription;
  String? _apiTreatment;
  bool _apiDone = false;
  String? _apiError;
  bool _isNetworkError = false;

  static const _scanUrl =
      'https://plant-pules-api.vercel.app/api/v1/scan/predict';

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
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'images': await MultipartFile.fromFile(widget.imagePath),
      });

      final response = await dio.post(
        _scanUrl,
        data: formData,
        options: Options(
          headers: {'token': userState.token},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (!mounted) return;

      final data = response.data['data'];
      final decision = (data?['finalDecision'] as String? ?? '').toLowerCase();
      final confidenceNum = (data?['averageConfidence'] as num? ?? 0);

      final results = data?['results'] as List?;
      final firstResult = results?.isNotEmpty == true
          ? results!.first as Map<String, dynamic>?
          : null;

      if (decision == 'not_lettuce') {
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

      setState(() {
        _apiStatus = decision == 'healthy' ? 'Healthy' : 'Diseased';
        _apiConfidence = confidenceNum.toStringAsFixed(0);
        _apiDiseaseName = firstResult?['disease_name']?.toString();
        _apiDescription = firstResult?['description']?.toString();
        _apiTreatment = firstResult?['treatment']?.toString();
        _apiDone = true;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      _progressTimer?.cancel();
      _lineController?.stop();

      String errorMsg;
      bool isNetwork = false;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMsg =
              'Connection timed out. Please check your internet and try again.';
          isNetwork = true;
          break;
        case DioExceptionType.connectionError:
          errorMsg = 'No internet connection. Please try again.';
          isNetwork = true;
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode ?? 0;
          if (statusCode >= 500) {
            errorMsg = 'Server error. Please try again in a moment.';
          } else if (statusCode == 401) {
            errorMsg = 'Session expired. Please log in again.';
          } else {
            errorMsg = 'Something went wrong. Please try again.';
          }
          break;
        default:
          errorMsg = 'Something went wrong. Please try again.';
      }

      setState(() {
        _apiError = errorMsg;
        _isNetworkError = isNetwork;
        _apiDone = true;
      });
    } catch (e) {
      if (!mounted) return;
      _progressTimer?.cancel();
      _lineController?.stop();
      setState(() {
        _apiError = 'Something went wrong. Please try again.';
        _apiDone = true;
      });
    }
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
              _scanComplete ? _buildSuccessSection() : _buildProgressSection(),
              const SizedBox(height: 82),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final percent = (_progress * 100).toInt();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 21),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF5E9),
                  border: Border.all(
                    color: const Color(0xFF399B25),
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
                  color: Color(0xFF4A4A4A),
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
            backgroundColor: const Color(0xFFF5F5F5),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF399B25)),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSection() {
    if (_apiError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFADAD), width: 0.4),
            ),
            child: Row(
              children: [
                Icon(
                  _isNetworkError
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  color: const Color(0xFFD32F2F),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _apiError!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD32F2F),
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GreenButton(
            text: 'Try Again',
            onPress: () async {
              if (await Vibration.hasVibrator() == true) {
                Vibration.vibrate(duration: 30);
              } else {
                HapticFeedback.lightImpact();
              }
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
            },
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                color: Color(0xFF399B25),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "We've identified your plant species and health condition",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF4A4A4A),
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 20),
        GreenButton(
          text: 'See Result',
          onPress: () async {
            if (await Vibration.hasVibrator() == true) {
              Vibration.vibrate(duration: 50);
            } else {
              HapticFeedback.mediumImpact();
            }
            if (_resultSaved) {
              if (!mounted) return;
              Navigator.push(
                context,
                fadeSlideRoute(
                  ResultPage(
                    imagePath: widget.imagePath,
                    plantName: 'Lettuce',
                    status: _savedStatus!,
                    confidence: _apiConfidence ?? '0',
                    diseaseName: _apiDiseaseName,
                    description: _apiDescription,
                    treatment: _apiTreatment,
                  ),
                ),
              );
              return;
            }

            _resultSaved = true;
            final status = _apiStatus ?? 'Healthy';
            _savedStatus = status;

            scansState.add(
              ScanRecord(
                imagePath: widget.imagePath,
                plantName: 'Lettuce',
                status: status,
                imageUrl: null,
                confidence: _apiConfidence ?? '0',
                scanTime: DateTime.now(),
                diseaseName: _apiDiseaseName,
                description: _apiDescription,
                treatment: _apiTreatment,
              ),
            );
            await saveScans();

            if (!mounted) return;
            Navigator.push(
              context,
              fadeSlideRoute(
                ResultPage(
                  imagePath: widget.imagePath,
                  plantName: 'Lettuce',
                  status: _savedStatus!,
                  imageUrl: null,
                  confidence: _apiConfidence ?? '0',
                  diseaseName: _apiDiseaseName,
                  description: _apiDescription,
                  treatment: _apiTreatment,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
