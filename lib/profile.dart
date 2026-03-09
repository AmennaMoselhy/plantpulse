import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'change_password_sheet.dart';
import 'logout_sheet.dart';
import 'user_state.dart';

class Profile extends StatefulWidget {
  final String fullName;
  final void Function(String newName)? onNameChanged;

  const Profile({super.key, required this.fullName, this.onNameChanged});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _displayName = widget.fullName;
    userState.addListener(_onUserStateChanged);
  }

  void _onUserStateChanged() {
    if (mounted) setState(() {});
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
    if (image != null) {
      final bytes = await image.readAsBytes();
      final tempDir = await getTemporaryDirectory();
      final newPath =
          '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(newPath).writeAsBytes(bytes);
      userState.updateProfileImage(newPath);
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
      builder: (context) {
        return _EditProfileSheet(
          fullName: _displayName,
          onSave: (newName) {
            setState(() => _displayName = newName);
            widget.onNameChanged?.call(newName);
          },
        );
      },
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
      builder: (context) => _AccountSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 24,
                      color: Color(0XFF4A4A4A),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Profile",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0XFF1F1F1F),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 24),

              // ✅ صورة البروفايل الكبيرة مع إمكانية التغيير
              Stack(
                children: [
                  ClipOval(
                    child: userState.profileImagePath != null
                        ? Image.file(
                            File(userState.profileImagePath!),
                            width: size.width * 0.24,
                            height: size.height * 0.111,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/bigProfilePic.png',
                            width: size.width * 0.24,
                            height: size.height * 0.111,
                            fit: BoxFit.cover,
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
                          color: Color(0XFF399B25),
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
              const SizedBox(height: 16),
              Text(
                _displayName,
                style: const TextStyle(
                  color: Color(0XFF1F1F1F),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(
                icon: "profile-circle",
                label: 'Profile',
                onTap: _showEditProfileSheet,
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: "setting",
                label: 'Account Settings',
                onTap: _showAccountSettingsSheet,
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                icon: "logout",
                label: 'Logout',
                isLogout: true,
                onTap: () {
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
          color: const Color(0XFFF5F5F5),
          border: Border.all(color: const Color(0XFFCCCCCC), width: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset("assets/$icon.png", width: 24, height: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  color: isLogout
                      ? const Color(0XFFD32F2F)
                      : const Color(0XFF184110),
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

// ==================== Account Settings Sheet ====================

class _AccountSettingsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                color: const Color(0XFFF5F5F5),
                border: Border.all(color: const Color(0XFFCCCCCC), width: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/password-check.png",
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
                        color: Color(0XFF184110),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ==================== Edit Profile Sheet ====================

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
            // ✅ الصورة في الـ sheet بتاتع edit profile بتتغير هي كمان
            Stack(
              children: [
                ClipOval(
                  child: userState.profileImagePath != null
                      ? Image.file(
                          File(userState.profileImagePath!),
                          width: size.width * 0.24,
                          height: size.height * 0.111,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/bigProfilePic.png',
                          width: size.width * 0.24,
                          height: size.height * 0.111,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0XFF399B25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildEditField(label: 'Name', controller: _nameController),
            const SizedBox(height: 16),
            _buildEditField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final newName = _nameController.text.trim();
                  if (newName.isNotEmpty) widget.onSave(newName);
                  Navigator.pop(context);
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
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
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
              fontWeight: FontWeight.w400,
              color: Color(0xFF676767),
              fontFamily: 'Poppins',
            ),
            suffixIcon: const Icon(
              Icons.edit_outlined,
              color: Color(0xFF399B25),
              size: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFCCCCCC),
                width: 0.6,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF399B25),
                width: 1.5,
              ),
            ),
          ),
          onTap: () {
            controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: controller.text.length,
            );
          },
        ),
      ],
    );
  }
}
