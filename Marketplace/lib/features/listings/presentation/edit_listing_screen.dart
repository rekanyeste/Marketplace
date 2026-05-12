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
import '../domain/listing.dart';
import '../domain/listing_category.dart';
import '../providers.dart';
import 'listings_controller.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  final String listingId;
  const EditListingScreen({super.key, required this.listingId});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();

  ListingCategory _category = ListingCategory.other;
  ListingCondition _condition = ListingCondition.good;
  List<String> _existingImageUrls = [];
  final List<File> _newImageFiles = [];
  bool _initialized = false;

  void _initFromListing(Listing listing) {
    if (_initialized) return;
    _titleController.text = listing.title;
    _descController.text = listing.description;
    _priceController.text = listing.price.toStringAsFixed(0);
    _cityController.text = listing.city;
    _category = listing.category;
    _condition = listing.condition;
    _existingImageUrls = List.from(listing.imageUrls);
    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final total = _existingImageUrls.length + _newImageFiles.length;
    if (total >= 2) return;
    final files = await ImageHelper.pickMultipleFromGallery(maxImages: 2 - total);
    setState(() => _newImageFiles.addAll(files));
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(listingsControllerProvider.notifier).updateListing(
      listingId: widget.listingId,
      title: _titleController.text,
      description: _descController.text,
      category: _category,
      price: double.parse(_priceController.text.trim()),
      condition: _condition,
      city: _cityController.text,
      existingImageUrls: _existingImageUrls,
      newImageFiles: _newImageFiles.isNotEmpty ? _newImageFiles : null,
    );
    if (!mounted) return;
    if (success) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingStreamProvider(widget.listingId));
    final controllerState = ref.watch(listingsControllerProvider);

    return listingAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (listing) {
        if (listing == null) return const Scaffold(body: Center(child: Text('Listing not found')));
        _initFromListing(listing);

        return LoadingOverlay(
          isLoading: controllerState.isLoading,
          message: 'Saving...',
          child: Scaffold(
            appBar: AppBar(title: const Text('Edit Listing')),
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
                    Text('Photos (${_existingImageUrls.length + _newImageFiles.length}/2)', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 100, height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.cardDark,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.add_photo_alternate_rounded, color: AppColors.primary),
                            ),
                          ),
                          ..._existingImageUrls.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                child: Image.network(e.value, width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(top: 4, right: 4, child: GestureDetector(
                                onTap: () => setState(() => _existingImageUrls.removeAt(e.key)),
                                child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                              )),
                            ]),
                          )),
                          ..._newImageFiles.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Stack(children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                                child: kIsWeb ? Image.network(e.value.path, width: 100, height: 100, fit: BoxFit.cover) : Image.file(e.value, width: 100, height: 100, fit: BoxFit.cover),
                              ),
                              Positioned(top: 4, right: 4, child: GestureDetector(
                                onTap: () => setState(() => _newImageFiles.removeAt(e.key)),
                                child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                              )),
                            ]),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(controller: _titleController, labelText: 'Title', hintText: 'Title', validator: (v) => Validators.required(v, 'Title'), maxLength: 80),
                    const SizedBox(height: 20),
                    AppTextField(controller: _priceController, labelText: 'Price (Ft)', hintText: '0', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, validator: Validators.price),
                    const SizedBox(height: 20),
                    Text('Category', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: ListingCategory.values.map((c) => ChoiceChip(label: Text(c.label), selected: _category == c, onSelected: (_) => setState(() => _category = c), selectedColor: AppColors.primary.withValues(alpha: 0.2))).toList()),
                    const SizedBox(height: 20),
                    Text('Condition', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: ListingCondition.values.map((c) => ChoiceChip(label: Text(c.label), selected: _condition == c, onSelected: (_) => setState(() => _condition = c), selectedColor: AppColors.primary.withValues(alpha: 0.2))).toList()),
                    const SizedBox(height: 20),
                    AppTextField(controller: _cityController, labelText: 'City', hintText: 'City', prefixIcon: Icons.location_on_outlined, validator: Validators.city),
                    const SizedBox(height: 20),
                    AppTextField(controller: _descController, labelText: 'Description', hintText: 'Describe your item...', maxLines: 5, maxLength: 1000, validator: (v) => Validators.minLength(v, 10, 'Description')),
                    const SizedBox(height: 32),
                    AppButton(label: 'Save Changes', onPressed: _handleSave, isLoading: controllerState.isLoading),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            ),
          ),
          ),
        );
      },
    );
  }
}
