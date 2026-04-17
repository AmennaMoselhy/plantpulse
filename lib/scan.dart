import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'scan_processing.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null || !mounted) return;

      final tempDir = await getTemporaryDirectory();
      final String newPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(image.path).copy(newPath);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanProcessing(imagePath: newPath),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access image. Please check permissions.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Scan Your Plant!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: Color(0XFF1F1F1F),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Start Scan or upload a plant image to detect any disease instantly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0XFF4A4A4A),
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: size.width * 0.56,
                  height: size.width * 0.56,
                  child: Stack(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/lettuce.png",
                          height: size.width * 0.41,
                          width: size.width * 0.38,
                        ),
                      ),
                      Center(child: Image.asset("assets/border.png")),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _buildButton(
                label: 'Start Scan',
                icon: Image.asset("assets/qrcode.png", height: 24, width: 24),
                onPressed: () => _pickImage(ImageSource.camera),
                backgroundColor: const Color(0XFF399B25),
                textColor: Colors.white,
                isOutlined: false,
              ),
              const SizedBox(height: 16),
              _buildButton(
                label: 'Upload From Gallery',
                icon: const Icon(
                  Icons.image,
                  size: 24,
                  color: Color(0xFF399B25),
                ),
                onPressed: () => _pickImage(ImageSource.gallery),
                backgroundColor: Colors.white,
                textColor: const Color(0xFF399B25),
                isOutlined: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Widget icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required bool isOutlined,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          side: isOutlined
              ? const BorderSide(color: Color(0xFF399B25), width: 0.6)
              : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: textColor,
              ),
            ),
            const SizedBox(width: 10),
            icon,
          ],
        ),
      ),
    );
  }
}
