import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../providers/mods_provider.dart';
import '../../widgets/cyber_card.dart';
import '../../widgets/search_header.dart';
import '../config/config_screen.dart';
import 'mod_detail_screen.dart';

class ModsScreen extends StatefulWidget {
  const ModsScreen({super.key});

  @override
  State<ModsScreen> createState() => _ModsScreenState();
}

class _ModsScreenState extends State<ModsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modsProvider = context.watch<ModsProvider>();
    final items = modsProvider.filteredMods;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => modsProvider.loadMods(),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Avatar World - City Life Cute',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'COLLECTION // ${items.length} MODS',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.neonGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'ONLINE',
                                  style: TextStyle(
                                    color: AppColors.neonGreen,
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
                    onSearchChanged: (q) => modsProvider.setSearchQuery(q),
                    categories: modsProvider.categories,
                    selectedCategory: modsProvider.selectedCategory,
                    onCategorySelected: (c) =>
                        modsProvider.selectCategory(c),
                    selectedFilter: modsProvider.filterType,
                    onFilterSelected: (f) => modsProvider.setFilterType(f),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),

              // Mods Grid / Empty State
              if (modsProvider.isLoading && items.isEmpty)
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
                            Icons.layers_clear_outlined,
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
                        final mod = items[index];
                        return CyberCard(
                          title: mod.title,
                          description: mod.description,
                          remoteImagePath:
                              '${ApiConstants.modsFolder}/${mod.image}',
                          isNew: mod.isNew,
                          isTop: mod.isTop,
                          isFavorite: mod.isFavorite,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ModDetailScreen(mod: mod),
                              ),
                            );
                          },
                          onFavoriteToggle: () =>
                              modsProvider.toggleFavorite(mod),
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
