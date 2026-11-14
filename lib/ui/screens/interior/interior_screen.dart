import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../providers/houses_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/search_header.dart';
import '../config/config_screen.dart';
import 'house_detail_screen.dart';

class InteriorScreen extends StatefulWidget {
  const InteriorScreen({super.key});

  @override
  State<InteriorScreen> createState() => _InteriorScreenState();
}

class _InteriorScreenState extends State<InteriorScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final housesProvider = context.watch<HousesProvider>();
    final items = housesProvider.filteredHouses;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => housesProvider.loadHouses(),
          child: CustomScrollView(
            slivers: [
              // Top Title Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.interior,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'HABITAT // 02 · ${items.length} BLUEPRINTS',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.cyanAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.cyanAccent.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.cyanAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'SYNCED',
                                  style: TextStyle(
                                    color: AppColors.cyanAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.settings_outlined,
                                color: AppColors.textSecondary, size: 22),
                            onPressed: () => ConfigScreen.show(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Search & Filter Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SearchHeader(
                    controller: _searchController,
                    onSearchChanged: (q) =>
                        housesProvider.setSearchQuery(q),
                    categories: housesProvider.categories,
                    selectedCategory: housesProvider.selectedCategory,
                    onCategorySelected: (c) =>
                        housesProvider.selectCategory(c),
                    selectedFilter: housesProvider.filterType,
                    onFilterSelected: (f) =>
                        housesProvider.setFilterType(f),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // Houses Grid / Empty State
              if (housesProvider.isLoading && items.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                )
              else if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.home_work_outlined,
                            size: 56,
                            color: AppColors.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            AppStrings.noMatch,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            AppStrings.noMatchSub,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final house = items[index];
                        return CyberCard(
                          title: house.title,
                          description: house.description,
                          remoteImagePath:
                              '${ApiConstants.housesFolder}/${house.image}',
                          isNew: house.isNew,
                          isTop: house.isTop,
                          isFavorite: house.isFavorite,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    HouseDetailScreen(house: house),
                              ),
                            );
                          },
                          onFavoriteToggle: () =>
                              housesProvider.toggleFavorite(house),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
