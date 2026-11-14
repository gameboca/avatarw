import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../providers/mods_provider.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final FilterType selectedFilter;
  final ValueChanged<FilterType> onFilterSelected;

  const SearchHeader({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.surfaceBorder,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: AppStrings.scanParts,
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Filter pills (ALL, NEW, TOP, FAVORITES)
        Row(
          children: [
            _buildFilterPill('ALL', FilterType.all),
            const SizedBox(width: 8),
            _buildFilterPill('NEW', FilterType.isNew),
            const SizedBox(width: 8),
            _buildFilterPill('TOP', FilterType.isTop),
            const SizedBox(width: 8),
            _buildFilterPill('SAVED', FilterType.favorites,
                icon: Icons.bookmark_rounded),
          ],
        ),

        const SizedBox(height: 14),

        // Categories horizontal list
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat == selectedCategory;
              return GestureDetector(
                onTap: () => onCategorySelected(cat),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceBorder,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat.toUpperCase(),
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterPill(String label, FilterType type, {IconData? icon}) {
    final isSelected = selectedFilter == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterSelected(type),
        child: Container(
          height: 34,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
