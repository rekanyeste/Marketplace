import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/image_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../domain/listing_category.dart';
import '../../profile/providers.dart';
import 'listings_controller.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();

  ListingCategory _selectedCategory = ListingCategory.other;
  ListingCondition _selectedCondition = ListingCondition.good;
  final List<File> _imageFiles = [];

  @override
  void initState() {
    super.initState();
    // Pre-fill city from profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(currentProfileProvider).value;
      if (profile != null && _cityController.text.isEmpty) {
        _cityController.text = profile.city;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_imageFiles.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 2 images allowed')),
      );
      return;
    }

    final remaining = 2 - _imageFiles.length;
    final files = await ImageHelper.pickMultipleFromGallery(
      maxImages: remaining,
    );
    setState(() => _imageFiles.addAll(files));
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one image')),
      );
      return;
    }

    final listingId =
        await ref.read(listingsControllerProvider.notifier).createListing(
              title: _titleController.text,
              description: _descriptionController.text,
              category: _selectedCategory,
              price: double.parse(_priceController.text.trim()),
              condition: _selectedCondition,
              city: _cityController.text,
              imageFiles: _imageFiles,
            );

    if (!mounted) return;

    if (listingId != null) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing created!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create listing'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(listingsControllerProvider);
    final isLoading = controllerState.isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      message: 'Creating listing...',
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Listing')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Images ──
                Text('Photos', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  'Add up to 2 photos • ${_imageFiles.length}/2',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Add button
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1.5,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                color: AppColors.primary,
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text('Add', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                      // Existing images
                      ..._imageFiles.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd),
                                    child: kIsWeb
                                        ? Image.network(
                                            entry.value.path,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            entry.value,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => setState(() =>
                                          _imageFiles.removeAt(entry.key)),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ──
                AppTextField(
                  controller: _titleController,
                  labelText: 'Title',
                  hintText: 'What are you selling?',
                  validator: (v) => Validators.required(v, 'Title'),
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // ── Price ──
                AppTextField(
                  controller: _priceController,
                  labelText: 'Price (Ft)',
                  hintText: '0.00',
                  prefixIcon: Icons.attach_money_rounded,
                  keyboardType: TextInputType.number,
                  validator: Validators.price,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // ── Category ──
                Text('Category', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ListingCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(cat.label),
                      avatar: Icon(cat.icon, size: 18),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ── Condition ──
                Text('Condition', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ListingCondition.values.map((cond) {
                    final isSelected = _selectedCondition == cond;
                    return ChoiceChip(
                      label: Text(cond.label),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => _selectedCondition = cond),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // ── City ──
                AppTextField(
                  controller: _cityController,
                  labelText: 'City',
                  hintText: 'Where is this item?',
                  prefixIcon: Icons.location_on_outlined,
                  validator: Validators.city,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                // ── Description ──
                AppTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  hintText: 'Describe your item in detail...',
                  maxLines: 5,
                  maxLength: 1000,
                  validator: (v) => Validators.minLength(v, 10, 'Description'),
                ),
                const SizedBox(height: 32),

                AppButton(
                  label: 'Publish Listing',
                  onPressed: _handleCreate,
                  isLoading: isLoading,
                  icon: Icons.publish_rounded,
                ),
                const SizedBox(height: 24),
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
