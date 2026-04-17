import 'dart:io';
import 'package:flutter/material.dart';
import 'user_state.dart';

class ResultPage extends StatefulWidget {
  final String imagePath;
  final String plantName;
  final String status;
  final String confidence;
  final String? imageUrl;
  final bool fromRecentScan;

  const ResultPage({
    super.key,
    required this.imagePath,
    required this.plantName,
    this.imageUrl,
    required this.status,
    required this.confidence,
    this.fromRecentScan = false,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final Future<bool> _imageExistsFuture = File(widget.imagePath).exists();

  bool get isHealthy => widget.status == 'Healthy';

  void _handleBack() {
    if (widget.fromRecentScan) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        'HomePage',
            (route) => false,
        arguments: {
          'firstName': userState.fullName.isNotEmpty
              ? userState.fullName.split(' ')[0]
              : '',
          'fullName': userState.fullName,
          'email': userState.email,
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _handleBack,
            child: const Icon(
              Icons.arrow_back_ios,
              size: 24,
              color: Color(0XFF4A4A4A),
            ),
          ),
          const Expanded(
            child: Text(
              'Result Page',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Color(0xFF1F1F1F),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildImage(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
            ? Image.network(
                widget.imageUrl!,
                width: double.infinity,
                height: size.height * 0.25,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: size.height * 0.25,
                  color: const Color(0xFFD9D9D9),
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey,
                  ),
                ),
              )
            : FutureBuilder<bool>(
                future: _imageExistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.data == true) {
                    return Image.file(
                      File(widget.imagePath),
                      width: double.infinity,
                      height: size.height * 0.25,
                      fit: BoxFit.cover,
                    );
                  }
                  return Container(
                    width: double.infinity,
                    height: size.height * 0.25,
                    color: const Color(0xFFD9D9D9),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
      ),
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Color(0xFF000000),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isHealthy
                  ? const Color(0xFFEBF5E9)
                  : const Color(0xFFFBEAEA),
              borderRadius: BorderRadius.circular(63),
              border: Border.all(
                color: isHealthy
                    ? const Color(0xFFA4D19B)
                    : const Color(0xFFEB9F9F),
                width: 0.4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isHealthy ? Icons.check_circle_outline : Icons.error_outline,
                  size: 13,
                  color: isHealthy
                      ? const Color(0xFF399B25)
                      : const Color(0xFFD32F2F),
                ),
                const SizedBox(width: 4),
                Text(
                  isHealthy ? 'Healthy Condition' : 'Issue Detected',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: isHealthy
                        ? const Color(0xFF399B25)
                        : const Color(0xFFD32F2F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHealthy ? const Color(0xFFEBF5E9) : const Color(0xFFFBEAEA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isHealthy
                ? const Color(0xFFA4D19B)
                : const Color(0xFFEB9F9F),
            width: 0.4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy ? Icons.check_circle_outline : Icons.error_outline,
                  color: isHealthy
                      ? const Color(0xFF399B25)
                      : const Color(0xFFD32F2F),
                  size: 24,
                ),
                const SizedBox(width: 4),
                Text(
                  isHealthy
                      ? 'Your plant is healthy and thriving!'
                      : 'Detected Disease',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF4A4A4A),
                  ),
                ),
              ],
            ),
            if (!isHealthy) ...[
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 28),
                child: Text(
                  'Disease Detected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                    color: Color(0xFFD32F2F),
                  ),
                ),
              ),
            ],
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
                color: const Color(0XFFFFFFFF),
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
                        widget.confidence,
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

  Widget _buildCareTips() {
    final tips = isHealthy
        ? [
            'Use clean, fresh water',
            'Maintain proper temperature',
            'Provide balanced lighting',
            'Ensure good air circulation',
          ]
        : [
            'Change the water immediately',
            'Adjust nutrient solution',
            'Avoid excessive light',
            'Remove affected leaves',
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
                Text(
                  isHealthy
                      ? 'Care Tips for Ongoing Health'
                      : 'Recommended Treatment Steps',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF1F1F1F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Color(0xFF1F1F1F), fontSize: 10),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1F1F1F),
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
