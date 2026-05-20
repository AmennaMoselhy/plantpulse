import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'change_password_sheet.dart';
import 'logout_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'user_state.dart';
import 'recent_scan.dart';
import 'contact_us_sheet.dart';
import 'crop_screen.dart';
import 'package:vibration/vibration.dart';
import 'app_navigator.dart';
import 'legal_page.dart';
import 'faq_page.dart';

Future<bool?> showSavePhotoDialog(BuildContext ctx, Uint8List imageBytes) {
  return showDialog<bool>(
    context: ctx,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Save Profile Photo?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: Color(0xFF1F1F1F),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.memory(
              imageBytes,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Use this photo as your profile picture?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'Poppins',
              color: Color(0xFF676767),
            ),
          ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF399B25),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF399B25),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                ),
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
    await dio.put(
      'https://plant-pules-api.vercel.app/api/v1/users/profile',
      data: formData,
      options: Options(headers: {'token': userState.token}),
    );
  } catch (_) {}
}

class Profile extends StatefulWidget {
  final String fullName;
  final String gender;
  final void Function(String newName)? onNameChanged;

  const Profile({
    super.key,
    required this.fullName,
    this.onNameChanged,
    required this.gender,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String _displayName;

  void _showFullScreenPhoto(BuildContext context) {
    final hasPhoto =
        userState.profileImagePath != null &&
        userState.profileImagePath!.isNotEmpty;

    Navigator.push(
      context,
      fadeSlideRoute(
        _FullScreenPhotoPage(
          imagePath: hasPhoto ? userState.profileImagePath! : null,
          gender: userState.gender,
          onEditTap: () {
            Navigator.of(context).pop();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) _pickProfileImage();
            });
          },
          onDeleteTap: hasPhoto
              ? () {
                  Navigator.of(context).pop();
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (mounted) _confirmRemovePhoto();
                  });
                }
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _displayName = userState.fullName.isNotEmpty
        ? userState.fullName
        : widget.fullName;
    userState.addListener(_onUserStateChanged);
  }

  void _onUserStateChanged() {
    if (mounted) setState(() => _displayName = userState.fullName);
  }

  @override
  void didUpdateWidget(covariant Profile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fullName != oldWidget.fullName) {
      _displayName = widget.fullName;
    }
  }

  @override
  void dispose() {
    userState.removeListener(_onUserStateChanged);
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    final croppedBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => CropScreen(imageBytes: bytes, isProfile: true),
      ),
    );

    if (croppedBytes == null || !mounted) return;

    final confirmed = await showSavePhotoDialog(context, croppedBytes);
    if (confirmed != true || !mounted) return;

    final tempDir = await getApplicationDocumentsDirectory();
    final newPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(newPath).writeAsBytes(croppedBytes);
    userState.updateProfileImage(newPath);
    await uploadProfileImage(newPath);
    if (mounted) setState(() {});
  }

  void _showPhotoOptionsSheet() {
    final hasPhoto =
        userState.profileImagePath != null &&
        userState.profileImagePath!.isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            const SizedBox(height: 16),
            const Text(
              'Profile photo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 16),
            _photoOption(
              icon: Icons.photo_library_outlined,
              iconColor: const Color(0xFF399B25),
              bgColor: const Color(0xFFEAF3DE),
              title: 'Change photo',
              subtitle: 'Choose from your gallery',
              onTap: () {
                Navigator.pop(ctx);
                _pickProfileImage();
              },
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 12),
              _photoOption(
                icon: Icons.delete_outline,
                iconColor: const Color(0xFFD32F2F),
                bgColor: const Color(0xFFFFEBEB),
                title: 'Remove photo',
                subtitle: 'Reset to default picture',
                titleColor: const Color(0xFFD32F2F),
                onTap: () async {
                  if (await Vibration.hasVibrator() == true) {
                    Vibration.vibrate(duration: 50);
                  } else {
                    HapticFeedback.mediumImpact();
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  _confirmRemovePhoto();
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _photoOption({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCCCCCC), width: 0.4),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: titleColor ?? const Color(0xFF184110),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: Color(0xFF676767),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF222222),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemovePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
        actionsPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFD32F2F),
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Remove profile photo?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Color(0xFF1F1F1F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your profile picture will be reset to the default avatar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                color: Color(0xFF676767),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        actions: [
          const Divider(height: 0.5, thickness: 0.5),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF676767),
                    ),
                  ),
                ),
              ),
              Container(width: 0.5, height: 48, color: const Color(0xFFCCCCCC)),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text(
                    'Remove',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final oldPath = userState.profileImagePath;
    userState.updateProfileImage('');
    if (mounted) setState(() {});

    if (oldPath != null) {
      try {
        final file = File(oldPath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _EditProfileSheet(
        fullName: _displayName,
        onSave: (newName) {
          setState(() => _displayName = newName);
          widget.onNameChanged?.call(newName);
        },
      ),
    );
  }

  void _showAccountSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AccountSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imgW = (size.width * 0.24).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
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
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1F1F1F),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _showFullScreenPhoto(context),
                onLongPress: _showPhotoOptionsSheet,
                child: Stack(
                  children: [
                    ClipOval(
                      child:
                          userState.profileImagePath != null &&
                              userState.profileImagePath!.isNotEmpty
                          ? Image.file(
                              File(userState.profileImagePath!),
                              width: size.width * 0.24,
                              height: size.height * 0.111,
                              fit: BoxFit.cover,
                              cacheWidth: imgW,
                            )
                          : Image.asset(
                              userState.gender.toLowerCase() == 'female'
                                  ? 'assets/bigProfilePic.png'
                                  : 'assets/male.png',
                              width: size.width * 0.24,
                              height: size.height * 0.111,
                              fit: BoxFit.cover,
                              cacheWidth: imgW,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF399B25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(
                icon: 'profile-circle',
                label: 'Edit Profile',
                onTap: _showEditProfileSheet,
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: 'setting',
                label: 'Account Settings',
                onTap: _showAccountSettingsSheet,
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: 'contact-us',
                label: 'Contact Us',
                onTap: () async {
                  if (await Vibration.hasVibrator() == true) {
                    Vibration.vibrate(duration: 30);
                  } else {
                    HapticFeedback.lightImpact();
                  }
                  if (!context.mounted) return;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => const ContactUsSheet(),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: 'faq',
                label: 'FAQ',
                onTap: () => Navigator.push(
                  context,
                  fadeSlideRoute(const FaqPage()),
                ),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: 'logout',
                label: 'Logout',
                isLogout: true,
                onTap: () {
                  Vibration.hasVibrator().then((hasVibrator) {
                    if (hasVibrator == true) {
                      Vibration.vibrate(duration: 30);
                    } else {
                      HapticFeedback.lightImpact();
                    }
                  });
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (context) => const LogoutSheet(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          border: Border.all(color: const Color(0xFFCCCCCC), width: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/$icon.png',
              width: 24,
              height: 24,
              color: isLogout ? const Color(0xFFD32F2F) : const Color(0xFF399B25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: isLogout
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF184110),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 19,
              color: Color(0xFF222222),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountSettingsSheet extends StatefulWidget {
  const _AccountSettingsSheet();

  @override
  State<_AccountSettingsSheet> createState() => _AccountSettingsSheetState();
}

class _AccountSettingsSheetState extends State<_AccountSettingsSheet> {
  bool _deletingAccount = false;

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: Color(0xFFD32F2F),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF399B25), fontFamily: 'Poppins'),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFD32F2F), fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingAccount = true);

    try {
      final dio = Dio();
      await dio.delete(
        'https://plant-pules-api.vercel.app/api/v1/users/profile',
        options: Options(headers: {'token': userState.token}),
      );

      await userState.clearAll();
      scansState.clear();
      await saveScans();

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('Login', (r) => false);

      Fluttertoast.showToast(
        msg: 'Account deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 14,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete account. Please try again.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, fadeSlideRoute(const LegalPage()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFCCCCCC), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    color: Color(0xFF399B25),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Privacy & Terms',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF184110),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 19,
                    color: Color(0xFF222222),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (context) => const ChangePasswordSheet(),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFCCCCCC), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/password-check.png',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFF184110),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 19,
                    color: Color(0xFF222222),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _deletingAccount
                ? null
                : () async {
                    if (await Vibration.hasVibrator() == true) {
                      Vibration.vibrate(duration: 100);
                    } else {
                      HapticFeedback.heavyImpact();
                    }
                    _handleDeleteAccount();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                border: Border.all(color: const Color(0xFFFFADAD), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFD32F2F),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                  ),
                  if (_deletingAccount)
                    const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFD32F2F),
                      ),
                    )
                  else
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 19,
                      color: Color(0xFFD32F2F),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final String fullName;
  final void Function(String newName) onSave;

  const _EditProfileSheet({required this.fullName, required this.onSave});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _selectedGender = userState.gender;
  bool _nameError = false;

  // bool _emailError = false;
  // String? _emailErrorMessage;
  // bool _isCheckingEmail = false;

  @override
  void initState() {
    super.initState();
    _selectedGender = userState.gender;
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: userState.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    final croppedBytes = await Navigator.push<Uint8List>(
      context,
      MaterialPageRoute(
        builder: (_) => CropScreen(imageBytes: bytes, isProfile: true),
      ),
    );

    if (croppedBytes == null || !mounted) return;

    final confirmed = await showSavePhotoDialog(context, croppedBytes);
    if (confirmed != true || !mounted) return;

    final tempDir = await getApplicationDocumentsDirectory();
    final newPath =
        '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(newPath).writeAsBytes(croppedBytes);
    userState.updateProfileImage(newPath);
    await uploadProfileImage(newPath);
    if (mounted) setState(() {});
  }

  Future<void> _handleSave() async {
    final newName = _nameController.text.trim();
    // final newEmail = _emailController.text.trim();

    if (newName.length < 5) {
      setState(() => _nameError = true);
      return;
    }
    setState(() => _nameError = false);

    try {
      final dio = Dio();
      await dio.put(
        'https://plant-pules-api.vercel.app/api/v1/users/profile',
        data: {
          'name': newName,
          'gender': _selectedGender,
          'email': _emailController.text.trim(),
        },
        options: Options(headers: {'token': userState.token}),
      );

      widget.onSave(newName);
      userState.updateFullName(newName);
      userState.updateEmail(_emailController.text.trim());
      userState.updateGender(_selectedGender);

      if (!mounted) return;
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: 'Profile updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFF399B25),
        textColor: Colors.white,
        fontSize: 14,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong. Please try again.',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
          ),
          backgroundColor: Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imgW = (size.width * 0.24).toInt();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
              const SizedBox(height: 24),
              Stack(
                children: [
                  Container(
                    width: size.width * 0.24,
                    height: size.height * 0.111,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEEEEEE),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        (userState.profileImagePath != null &&
                            userState.profileImagePath!.isNotEmpty)
                        ? Image.file(
                            File(userState.profileImagePath!),
                            fit: BoxFit.cover,
                            cacheWidth: imgW,
                          )
                        : Image.asset(
                            _selectedGender.toLowerCase() == 'female'
                                ? 'assets/bigProfilePic.png'
                                : 'assets/male.png',
                            fit: BoxFit.cover,
                            cacheWidth: imgW,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFF399B25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildEditField(
                label: 'Name',
                controller: _nameController,
                hasError: _nameError,
                errorText: 'Name must be at least 5 characters',
                onClearError: () => setState(() => _nameError = false),
              ),
              const SizedBox(height: 16),
              _buildEditField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                hasError: false,
                enabled: false,
                errorText: '',
                onClearError: () {},
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text("Male"),
                    selected: _selectedGender == "male",
                    onSelected: (_) => setState(() => _selectedGender = "male"),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text("Female"),
                    selected: _selectedGender == "female",
                    onSelected: (_) =>
                        setState(() => _selectedGender = "female"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (await Vibration.hasVibrator() == true) {
                      Vibration.vibrate(duration: 50);
                    } else {
                      HapticFeedback.mediumImpact();
                    }
                    if (!context.mounted) return;
                    _handleSave();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF399B25),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    bool enabled = true,
    required String label,
    required TextEditingController controller,
    required bool hasError,
    required String errorText,
    required VoidCallback onClearError,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F1F1F),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          enabled: enabled,
          controller: controller,
          keyboardType: keyboardType,
          enableInteractiveSelection: true,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1F1F1F),
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF676767),
              fontFamily: 'Poppins',
            ),
            suffixIcon: Icon(
              enabled ? Icons.edit_outlined : Icons.lock_outline,
              color: enabled
                  ? const Color(0xFF399B25)
                  : const Color(0xFF9E9E9E),
              size: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFCCCCCC),
                width: hasError ? 1.0 : 0.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFF399B25),
                width: 1.5,
              ),
            ),
            errorText: hasError ? errorText : null,
            errorStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              color: Color(0xFFD32F2F),
            ),
          ),
          onTap: () => controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          ),
          onChanged: (_) {
            if (hasError) onClearError();
          },
        ),
      ],
    );
  }
}

class _FullScreenPhotoPage extends StatelessWidget {
  final String? imagePath;
  final String gender;
  final VoidCallback onEditTap;
  final VoidCallback? onDeleteTap;

  const _FullScreenPhotoPage({
    required this.imagePath,
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
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 26,
                    ),
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
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 26,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: imagePath != null
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
                  _option(
                    icon: Icons.photo_library_outlined,
                    iconColor: const Color(0xFF399B25),
                    bgColor: const Color(0xFFEAF3DE),
                    title: 'Change photo',
                    subtitle: 'Choose from your gallery',
                    onTap: onEditTap,
                  ),
                  if (onDeleteTap != null) ...[
                    const SizedBox(height: 12),
                    _option(
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

  Widget _option({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCCCCCC), width: 0.4),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: titleColor ?? const Color(0xFF184110),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: Color(0xFF676767),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: titleColor ?? const Color(0xFF222222),
            ),
          ],
        ),
      ),
    );
  }
}
