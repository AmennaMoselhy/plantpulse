import 'dart:io';
import 'package:flutter/material.dart';
import 'package:PlantPulse/widgets/photo_option_item.dart';

class FullScreenPhotoPage extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final String gender;
  final VoidCallback onEditTap;
  final VoidCallback? onDeleteTap;

  const FullScreenPhotoPage({
    super.key,
    required this.imagePath,
    this.imageUrl,
    required this.gender,
    required this.onEditTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                  ),
                  const Expanded(
                    child: Text(
                      'Profile picture',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  if (onDeleteTap != null)
                    IconButton(
                      onPressed: onDeleteTap,
                      icon: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    gender.toLowerCase() == 'female'
                        ? 'assets/bigProfilePic.png'
                        : 'assets/male.png',
                    fit: BoxFit.contain,
                  ),
                )
                    : imagePath != null && imagePath!.isNotEmpty
                    ? Image.file(File(imagePath!), fit: BoxFit.contain)
                    : Image.asset(
                  gender.toLowerCase() == 'female'
                      ? 'assets/bigProfilePic.png'
                      : 'assets/male.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PhotoOptionItem(
                    icon: Icons.photo_library_outlined,
                    iconColor: const Color(0xFF399B25),
                    bgColor: const Color(0xFFEAF3DE),
                    title: 'Change photo',
                    subtitle: 'Choose from your gallery',
                    onTap: onEditTap,
                  ),
                  if (onDeleteTap != null) ...[
                    const SizedBox(height: 12),
                    PhotoOptionItem(
                      icon: Icons.delete_outline,
                      iconColor: const Color(0xFFD32F2F),
                      bgColor: const Color(0xFFFFEBEB),
                      title: 'Remove photo',
                      subtitle: 'Reset to default picture',
                      titleColor: const Color(0xFFD32F2F),
                      onTap: onDeleteTap!,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}