import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:PlantPulse/widgets/result_status_widgets.dart';
import 'package:PlantPulse/widgets/result_care_tips.dart';

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
                ResultNameAndBadge(
                  plantName: widget.plantName,
                  status: widget.status,
                  isHealthy: isHealthy,
                  diseaseName: widget.diseaseName,
                ),
                const SizedBox(height: 24),
                ResultMessageCard(isHealthy: isHealthy),
                const SizedBox(height: 12),
                ResultAccuracyRow(
                  isHealthy: isHealthy,
                  safeConfidence: safeConfidence,
                ),
                const SizedBox(height: 24),
                ResultCareTips(
                  isHealthy: isHealthy,
                  diseaseName: widget.diseaseName,
                  description: widget.description,
                  treatment: widget.treatment,
                ),
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
}