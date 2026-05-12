import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers.dart';
import 'profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  String? _profileImageUrl;
  bool _uploadingImage = false;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _initializeFromProfile() {
    if (_initialized) return;
    final profile = ref.read(currentProfileProvider).value;
    if (profile != null) {
      _nameController.text = profile.displayName;
      _cityController.text = profile.city;
      _profileImageUrl = profile.profileImageUrl;
      _initialized = true;
    }
  }

  Future<void> _pickProfileImage() async {
    setState(() => _uploadingImage = true);
    try {
      final base64 = await ImageHelper.pickAndConvertToBase64();
      if (base64 != null) {
        setState(() => _profileImageUrl = base64);
      }
    } finally {
      setState(() => _uploadingImage = false);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(profileControllerProvider.notifier)
        .updateProfile(
          displayName: _nameController.text,
          city: _cityController.text,
          profileImageUrl: _profileImageUrl,
        );

    if (!mounted) return;
    if (success) {
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    // Initialize fields from profile
    ref.watch(currentProfileProvider);
    _initializeFromProfile();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Avatar
              Center(
                child: GestureDetector(
                  onTap: _uploadingImage ? null : _pickProfileImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.surfaceDark,
                        backgroundImage:
                            _profileImageUrl != null
                                ? (_profileImageUrl!.startsWith('data:')
                                    ? MemoryImage(ImageHelper.decodeBase64DataUri(_profileImageUrl!)!)
                                    : NetworkImage(_profileImageUrl!) as ImageProvider)
                                : null,
                        child:
                            _profileImageUrl == null
                                ? const Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: AppColors.textTertiary,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              _uploadingImage
                                  ? const Padding(
                                    padding: EdgeInsets.all(6),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _nameController,
                labelText: 'Display Name',
                hintText: 'Your name',
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.displayName,
                maxLength: 30,
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _cityController,
                labelText: 'City / Region',
                hintText: 'Your location',
                prefixIcon: Icons.location_on_outlined,
                validator: Validators.city,
              ),
              const SizedBox(height: 40),
              AppButton(
                label: 'Save Changes',
                onPressed: _handleSave,
                isLoading: profileState.isLoading,
              ),
            ],
          ),
        ),
      ),
      ),
    ),
    );
  }
}
