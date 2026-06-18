import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:PlantPulse/state/user_state.dart';
import 'package:PlantPulse/screens/crop_screen.dart';
import 'package:PlantPulse/services/profile_image_utils.dart';
import 'edit_email_sheet.dart';

class EditProfileSheet extends StatefulWidget {
  final String fullName;
  final void Function(String newName) onSave;

  const EditProfileSheet({
    super.key,
    required this.fullName,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String _selectedGender = userState.gender;
  bool _nameError = false;

  @override
  void initState() {
    super.initState();
    _selectedGender = userState.gender;
    _nameController = TextEditingController(text: widget.fullName);
    _emailController = TextEditingController(text: userState.email);
    userState.addListener(_onUserStateChanged);
  }

  void _onUserStateChanged() {
    if (mounted) setState(() => _emailController.text = userState.email);
  }

  @override
  void dispose() {
    userState.removeListener(_onUserStateChanged);
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
    userState.updateProfileImageUrl('');
    userState.updateProfileImage(newPath);
    await uploadProfileImage(newPath);
    PaintingBinding.instance.imageCache.clear();
    if (mounted) setState(() {});
  }

  void _openEditEmail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => EditEmailSheet(
        onSave: (newEmail) {
          setState(() => _emailController.text = newEmail);
        },
      ),
    );
  }

  Future<void> _handleSave() async {
    final newName = _nameController.text.trim();
    if (newName.length < 5) {
      setState(() => _nameError = true);
      return;
    }
    setState(() => _nameError = false);

    try {
      final dio = Dio();

      // حدثي الاسم على الـ API
      if (newName != widget.fullName) {
        await dio.put(
          'https://plant-pules-api.vercel.app/api/v1/users/profile/name',
          data: {'name': newName},
          options: Options(
            headers: {'token': userState.token},
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        );
      }

      // احفظي locally
      widget.onSave(newName);
      userState.updateFullName(newName);
      userState.updateGender(_selectedGender); // بس locally مفيش API للـ gender

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
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to update profile';
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 13,
      );
    } catch (_) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: 'Something went wrong. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: const Color(0xFFD32F2F),
        textColor: Colors.white,
        fontSize: 13,
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
                        (userState.profileImageUrl != null &&
                            userState.profileImageUrl!.isNotEmpty)
                        ? Image.network(
                            userState.profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              _selectedGender.toLowerCase() == 'female'
                                  ? 'assets/bigProfilePic.png'
                                  : 'assets/male.png',
                              fit: BoxFit.cover,
                              cacheWidth: imgW,
                            ),
                          )
                        : (userState.profileImagePath != null &&
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
              GestureDetector(
                onTap: _openEditEmail,
                child: AbsorbPointer(
                  child: _buildEditField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hasError: false,
                    enabled: false,
                    errorText: '',
                    onClearError: () {},
                    forceEditIcon: true,
                  ),
                ),
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
    bool forceEditIcon = false,
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
              (enabled || forceEditIcon)
                  ? Icons.edit_outlined
                  : Icons.lock_outline,
              color: (enabled || forceEditIcon)
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFCCCCCC),
                width: 0.6,
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
