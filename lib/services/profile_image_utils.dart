import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:PlantPulse/state/user_state.dart';

Future<bool?> showSavePhotoDialog(BuildContext ctx, Uint8List imageBytes) {
  return showDialog<bool>(
    context: ctx,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Save Profile Photo?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              fontFamily: 'Poppins', color: Color(0xFF1F1F1F))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(child: Image.memory(imageBytes, width: 100, height: 100, fit: BoxFit.cover)),
          const SizedBox(height: 8),
          const Text('Use this photo as your profile picture?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontFamily: 'Poppins', color: Color(0xFF676767))),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF399B25)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Cancel',
                    style: TextStyle(color: Color(0xFF399B25), fontFamily: 'Poppins')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF399B25), elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save',
                    style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Future<void> uploadProfileImage(String localPath) async {
  if (userState.token.isEmpty) return;
  try {
    final dio = Dio();
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(localPath, filename: 'profile.jpg'),
    });
    final response = await dio.put(
      'https://plant-pules-api.vercel.app/api/v1/users/profile/image',
      data: formData,
      options: Options(headers: {'token': userState.token}),
    );
    final imageUrl = response.data?['data']?['profileImage'] as String?;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      userState.updateProfileImageUrl(imageUrl);
    }
  } catch (_) {}
}