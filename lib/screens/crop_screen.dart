import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final bool isProfile;

  const CropScreen({
    super.key,
    required this.imageBytes,
    required this.isProfile,
  });

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  final _controller = CropController();
  bool _hasCropped = false;
  bool _imageReady = false;

  @override
  void initState() {
    super.initState();
    final delay = widget.isProfile ? 300 : 300;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) setState(() => _imageReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: const Text(
          'Crop Image',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        leadingWidth: 80,
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              if (_hasCropped) {
                _controller.crop();
              } else {
                Navigator.pop(context, widget.imageBytes);
              }
            },
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF399B25),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Crop(
          image: widget.imageBytes,
          controller: _controller,
          aspectRatio: widget.isProfile ? 1 : null,
          onMoved: (_) {
            if (_imageReady) _hasCropped = true;
          },
          onCropped: (croppedImage) {
            Navigator.pop(context, croppedImage);
          },
        ),
      ),
    );
  }
}
