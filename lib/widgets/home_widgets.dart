import 'dart:io';
import 'package:flutter/material.dart';
import 'package:PlantPulse/state/user_state.dart';

class HomeHeader extends StatelessWidget {
  final String firstName;
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    required this.firstName,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi $firstName!',
                style: const TextStyle(color: Color(0xFF1F1F1F),
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const Text("Check Your Plants' Health Summary",
                style: TextStyle(color: Color(0xFF4A4A4A),
                    fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onProfileTap,
          child: userState.profileImageUrl != null &&
              userState.profileImageUrl!.isNotEmpty
              ? ClipOval(
            child: Image.network(
              userState.profileImageUrl!,
              width: 32, height: 32, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 34, height: 34,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFEFF3EE)),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  userState.gender.toLowerCase() == 'female'
                      ? 'assets/bigProfilePic.png'
                      : 'assets/male.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
              : userState.profileImagePath != null &&
              userState.profileImagePath!.isNotEmpty
              ? ClipOval(
            child: Image.file(
              File(userState.profileImagePath!),
              width: 32, height: 32, fit: BoxFit.cover, cacheWidth: 64,
            ),
          )
              : Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFFEFF3EE)),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              userState.gender.toLowerCase() == 'female'
                  ? 'assets/bigProfilePic.png'
                  : 'assets/male.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class HomeStatCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String value;
  final Color bgColor;
  final Color borderColor;

  const HomeStatCard({
    super.key,
    required this.imagePath,
    required this.label,
    required this.value,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 24, height: 24, cacheWidth: 48),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF1F1F1F),
                  fontSize: 12, fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(color: Color(0xFF1F1F1F),
                  fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeDidYouKnow extends StatelessWidget {
  const HomeDidYouKnow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5E9),
        border: Border.all(color: const Color(0xFF61AF51), width: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset('assets/didYouKnow.png', width: 24, height: 24, cacheWidth: 48),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Did you know?',
                    style: TextStyle(color: Color(0xFF1F1F1F),
                        fontSize: 12, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text(
                  'Overwatering causes yellow leaves. Water only when the top 2 inches of soil feel dry!',
                  style: TextStyle(color: Color(0xFF1F1F1F),
                      fontSize: 10, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}