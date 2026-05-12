import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../listings/domain/listing_category.dart';
import '../../domain/search_filters.dart';
import '../../providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late SearchFilters _filters;
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = ref.read(searchFiltersProvider);
    _minPriceCtrl.text = _filters.minPrice?.toStringAsFixed(0) ?? '';
    _maxPriceCtrl.text = _filters.maxPrice?.toStringAsFixed(0) ?? '';
    _cityCtrl.text = _filters.city ?? '';
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    final minPrice = double.tryParse(_minPriceCtrl.text);
    final maxPrice = double.tryParse(_maxPriceCtrl.text);
    final city = _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim();

    ref.read(searchFiltersProvider.notifier).updateFilters(
      _filters.copyWith(
        minPrice: minPrice,
        maxPrice: maxPrice,
        city: city,
        clearMinPrice: minPrice == null,
        clearMaxPrice: maxPrice == null,
        clearCity: city == null,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder:
          (_, controller) => Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: controller,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Filters', style: AppTextStyles.h2),
                    const Spacer(),
                    TextButton(
                      onPressed:
                          () => setState(() {
                            _filters = const SearchFilters();
                            _minPriceCtrl.clear();
                            _maxPriceCtrl.clear();
                            _cityCtrl.clear();
                          }),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category
                Text('Category', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filters.category == null,
                      onSelected:
                          (_) => setState(
                            () =>
                                _filters = _filters.copyWith(
                                  clearCategory: true,
                                ),
                          ),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    ...ListingCategory.values.map(
                      (c) => ChoiceChip(
                        label: Text(c.label),
                        avatar: Icon(c.icon, size: 18),
                        selected: _filters.category == c.name,
                        onSelected:
                            (_) => setState(
                              () =>
                                  _filters = _filters.copyWith(
                                    category: c.name,
                                  ),
                            ),
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Price range
                Text('Price Range', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _minPriceCtrl,
                        hintText: 'Min',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money_rounded,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '–',
                        style: TextStyle(color: AppColors.textTertiary),
                      ),
                    ),
                    Expanded(
                      child: AppTextField(
                        controller: _maxPriceCtrl,
                        hintText: 'Max',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Condition
                Text('Condition', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Any'),
                      selected: _filters.condition == null,
                      onSelected:
                          (_) => setState(
                            () =>
                                _filters = _filters.copyWith(
                                  clearCondition: true,
                                ),
                          ),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    ...ListingCondition.values.map(
                      (c) => ChoiceChip(
                        label: Text(c.label),
                        selected: _filters.condition == c.name,
                        onSelected:
                            (_) => setState(
                              () =>
                                  _filters = _filters.copyWith(
                                    condition: c.name,
                                  ),
                            ),
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // City
                AppTextField(
                  controller: _cityCtrl,
                  labelText: 'City',
                  hintText: 'Filter by city',
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 24),

                // Sort
                Text('Sort By', style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Newest'),
                      selected: _filters.sortBy == 'newest',
                      onSelected:
                          (_) => setState(
                            () =>
                                _filters = _filters.copyWith(sortBy: 'newest'),
                          ),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    ChoiceChip(
                      label: const Text('Price: Low to High'),
                      selected: _filters.sortBy == 'price_low',
                      onSelected:
                          (_) => setState(
                            () =>
                                _filters = _filters.copyWith(
                                  sortBy: 'price_low',
                                ),
                          ),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                    ChoiceChip(
                      label: const Text('Price: High to Low'),
                      selected: _filters.sortBy == 'price_high',
                      onSelected:
                          (_) => setState(
                            () =>
                                _filters = _filters.copyWith(
                                  sortBy: 'price_high',
                                ),
                          ),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                AppButton(
                  label: 'Apply Filters',
                  onPressed: _apply,
                  icon: Icons.check_rounded,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}
