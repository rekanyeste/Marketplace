import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'profile_controller.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  String? _profileImageUrl;
  bool _uploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
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

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(profileControllerProvider.notifier).createProfile(
              displayName: _nameController.text,
              city: _cityController.text,
              profileImageUrl: _profileImageUrl,
            );

    if (!mounted) return;
    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create profile'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isLoading = profileState.isLoading;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text('Set up your profile', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  'Tell buyers and sellers a bit about you',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 40),
                // Profile image picker
                Center(
                  child: GestureDetector(
                    onTap: _uploadingImage ? null : _pickProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: AppSizes.avatarLg,
                          backgroundColor: AppColors.surfaceDark,
                          backgroundImage: _profileImageUrl != null
                              ? (_profileImageUrl!.startsWith('data:')
                                  ? MemoryImage(ImageHelper.decodeBase64DataUri(_profileImageUrl!)!)
                                  : NetworkImage(_profileImageUrl!) as ImageProvider)
                              : null,
                          child: _profileImageUrl == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 48,
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
                              border: Border.all(
                                color: AppColors.scaffoldDark,
                                width: 2,
                              ),
                            ),
                            child: _uploadingImage
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
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'Tap to add photo (optional)',
                    style: AppTextStyles.caption,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _nameController,
                  labelText: 'Display Name',
                  hintText: 'How should people call you?',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: Validators.displayName,
                  maxLength: 30,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _cityController,
                  labelText: 'City / Region',
                  hintText: 'Where are you located?',
                  prefixIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.done,
                  validator: Validators.city,
                  onSubmitted: (_) => _handleCreate(),
                ),
                const SizedBox(height: 40),
                AppButton(
                  label: 'Complete Setup',
                  onPressed: _handleCreate,
                  isLoading: isLoading,
                  icon: Icons.check_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    ),
    );
  }
}
