import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final String plantName;
  final String status;
  final String confidence;
  final String? imageUrl;
  final bool fromRecentScan;
  final String? diseaseName;
  final String? description;
  final String? treatment;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.plantName,
    this.imageUrl,
    required this.status,
    required this.confidence,
    this.fromRecentScan = false,
    this.diseaseName,
    this.description,
    this.treatment,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final Future<bool> _imageExistsFuture = File(widget.imagePath).exists();

  bool get isHealthy => widget.status == 'Healthy';

  String get safeConfidence {
    if (widget.confidence.isEmpty ||
        widget.confidence == '—' ||
        widget.confidence == 'null') {
      return '0';
    }
    return widget.confidence;
  }

  Future<void> _shareResult() async {
    final status = widget.status;
    final plant = widget.plantName;
    final confidence = safeConfidence;
    final disease = widget.diseaseName != null ? '\nDisease: ${widget.diseaseName}' : '';
    final message = '🌿 Plant Pulse Scan Result\n\nPlant: $plant\nStatus: $status$disease\nAccuracy: $confidence%\n\nScanned with Plant Pulse App';

    try {
      if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
        final response = await Dio().get(
          widget.imageUrl!,
          options: Options(responseType: ResponseType.bytes),
        );
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/share_image.jpg');
        await file.writeAsBytes(response.data);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: message,
        );
      } else if (widget.imagePath.isNotEmpty) {
        final exists = await File(widget.imagePath).exists();
        if (exists) {
          await Share.shareXFiles(
            [XFile(widget.imagePath)],
            text: message,
          );
          return;
        }
        Share.share(message);
      } else {
        Share.share(message);
      }
    } catch (_) {
      Share.share(message);
    }
  }

  void _handleBack() {
    if (widget.fromRecentScan) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        'RecentScan',
        (route) => route.settings.name == 'HomePage',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                _buildImage(size),
                const SizedBox(height: 16),
                _buildNameAndBadge(),
                const SizedBox(height: 24),
                _buildMessageCard(),
                const SizedBox(height: 12),
                _buildAccuracyRow(),
                const SizedBox(height: 24),
                _buildCareTips(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 24,
              color: Color(0xFF4A4A4A),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Scan Result',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1F1F1F),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _shareResult,
            child: const Icon(
              Icons.share_rounded,
              size: 24,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(Size size) {
    Widget imageWidget;
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        widget.imageUrl!,
        width: double.infinity,
        height: size.height * 0.32,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(size),
      );
    } else if (widget.imagePath.isNotEmpty) {
      imageWidget = FutureBuilder<bool>(
        future: _imageExistsFuture,
        builder: (context, snap) {
          if (snap.data == true) {
            return Image.file(
              File(widget.imagePath),
              width: double.infinity,
              height: size.height * 0.32,
              fit: BoxFit.cover,
            );
          }
          return _imagePlaceholder(size);
        },
      );
    } else {
      imageWidget = _imagePlaceholder(size);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: imageWidget,
    );
  }

  Widget _imagePlaceholder(Size size) {
    return Container(
      width: double.infinity,
      height: size.height * 0.32,
      color: const Color(0xFFEBF5E9),
      child: const Icon(Icons.eco, size: 80, color: Color(0xFF399B25)),
    );
  }

  Widget _buildNameAndBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.plantName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
              fontFamily: 'Poppins',
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isHealthy
                      ? const Color(0xFFEBF5E9)
                      : const Color(0xFFFFEBEB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle : Icons.warning_rounded,
                      size: 14,
                      color: isHealthy
                          ? const Color(0xFF399B25)
                          : const Color(0xFFD32F2F),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isHealthy
                            ? const Color(0xFF399B25)
                            : const Color(0xFFD32F2F),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              if (!isHealthy && widget.diseaseName != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.diseaseName!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    final message = isHealthy
        ? 'Your plant looks healthy! Keep up the good care and continue monitoring regularly.'
        : 'Your plant shows signs of disease. Consider consulting an expert or adjusting care routines.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHealthy ? const Color(0xFFEBF5E9) : const Color(0xFFFFEBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isHealthy
                ? const Color(0xFFA4D19B)
                : const Color(0xFFFFADAD),
            width: 0.6,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isHealthy ? Icons.eco : Icons.healing,
              color: isHealthy
                  ? const Color(0xFF399B25)
                  : const Color(0xFFD32F2F),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA4D19B), width: 0.4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF399B25),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accuracy',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      Text(
                        '$safeConfidence%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFF399B25),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFCA9C), width: 0.4),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF8C27),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image Quality',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                      Text(
                        isHealthy ? 'Good' : 'Low',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                          color: Color(0xFFFF8C27),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _parseTreatment(String treatment) {
    if (treatment.contains('|||')) {
      return treatment
          .split('|||')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    String cleaned = treatment.trim();
    if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
      cleaned = cleaned.substring(1, cleaned.length - 1);
    }
    return cleaned
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Widget _buildCareTips() {
    final bool hasApiData =
        !isHealthy && (widget.diseaseName != null || widget.treatment != null);

    final tips = isHealthy
        ? [
            'Water regularly and avoid overwatering',
            'Ensure adequate sunlight exposure',
            'Use well-draining soil',
            'Apply balanced fertilizer monthly',
          ]
        : widget.treatment != null
        ? _parseTreatment(widget.treatment!)
        : [
            'Remove infected leaves immediately',
            'Improve air circulation around the plant',
            'Avoid wetting leaves when watering',
            'Consider using appropriate fungicide or pesticide',
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEBF5E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFA4D19B), width: 0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/lamp.png', width: 24, height: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isHealthy
                        ? 'Care Tips for Ongoing Health'
                        : hasApiData && widget.diseaseName != null
                        ? 'Treatment: ${widget.diseaseName}'
                        : 'Recommended Treatment Steps',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ],
            ),
            if (!isHealthy && widget.description != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.description!,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  fontFamily: 'Poppins',
                  color: Color(0xFF717171),
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF399B25),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontFamily: 'Poppins',
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
