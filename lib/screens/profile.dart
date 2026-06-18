import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:PlantPulse/state/user_state.dart';
import 'package:PlantPulse/sheets/profile/contact_us_sheet.dart';
import 'package:PlantPulse/sheets/profile/logout_sheet.dart';
import 'crop_screen.dart';
import 'package:PlantPulse/app_navigator.dart';
import 'faq_page.dart';
import 'package:PlantPulse/sheets/profile/account_settings_sheet.dart';
import 'package:PlantPulse/sheets/profile/edit_profile_sheet.dart';
import 'package:PlantPulse/services/profile_image_utils.dart';
import 'package:PlantPulse/widgets/photo_option_item.dart';
import 'full_screen_photo_page.dart';

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
    if (widget.fullName != oldWidget.fullName) _displayName = widget.fullName;
  }

  @override
  void dispose() {
    userState.removeListener(_onUserStateChanged);
    super.dispose();
  }

  void _showFullScreenPhoto(BuildContext context) {
    final hasPhoto =
        (userState.profileImageUrl != null &&
            userState.profileImageUrl!.isNotEmpty) ||
            (userState.profileImagePath != null &&
                userState.profileImagePath!.isNotEmpty);

    Navigator.push(
      context,
      fadeSlideRoute(
        FullScreenPhotoPage(
          imageUrl: userState.profileImageUrl,
          imagePath: userState.profileImagePath,
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
        '${tempDir.path}/profile_${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg';
    await File(newPath).writeAsBytes(croppedBytes);

    userState.updateProfileImageUrl('');
    userState.updateProfileImage(newPath);

    await uploadProfileImage(newPath);

    PaintingBinding.instance.imageCache.clear();
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
      builder: (ctx) =>
          Padding(
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
                PhotoOptionItem(
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
                  PhotoOptionItem(
                    icon: Icons.delete_outline,
                    iconColor: const Color(0xFFD32F2F),
                    bgColor: const Color(0xFFFFEBEB),
                    title: 'Remove photo',
                    subtitle: 'Reset to default picture',
                    titleColor: const Color(0xFFD32F2F),
                    onTap: () async {
                      if (await Vibration.hasVibrator() == true)
                        Vibration.vibrate(duration: 50);
                      else
                        HapticFeedback.mediumImpact();
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

  Future<void> _confirmRemovePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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
                  Container(
                      width: 0.5, height: 48, color: const Color(0xFFCCCCCC)),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
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
                    onTap: () =>
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
                        ),
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
                      userState.profileImageUrl != null &&
                          userState.profileImageUrl!.isNotEmpty
                          ? Image.network(
                        userState.profileImageUrl!,
                        width: size.width * 0.24,
                        height: size.height * 0.111,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset(
                              userState.gender.toLowerCase() == 'female'
                                  ? 'assets/bigProfilePic.png'
                                  : 'assets/male.png',
                              width: size.width * 0.24,
                              height: size.height * 0.111,
                              fit: BoxFit.cover,
                              cacheWidth: imgW,
                            ),
                      )
                          : userState.profileImagePath != null &&
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
                onTap: () =>
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
                      builder: (context) =>
                          EditProfileSheet(
                            fullName: _displayName,
                            onSave: (newName) {
                              setState(() => _displayName = newName);
                              widget.onNameChanged?.call(newName);
                            },
                          ),
                    ),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: 'setting',
                label: 'Account Settings',
                onTap: () =>
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
                      builder: (context) => const AccountSettingsSheet(),
                    ),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: 'contact-us',
                label: 'Contact Us',
                onTap: () async {
                  if (await Vibration.hasVibrator() == true)
                    Vibration.vibrate(duration: 30);
                  else
                    HapticFeedback.lightImpact();
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
                onTap: () =>
                    Navigator.push(context, fadeSlideRoute(const FaqPage())),
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: 'logout',
                label: 'Logout',
                isLogout: true,
                onTap: () {
                  Vibration.hasVibrator().then((hasVibrator) {
                    if (hasVibrator == true)
                      Vibration.vibrate(duration: 30);
                    else
                      HapticFeedback.lightImpact();
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
              color: isLogout
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFF399B25),
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
