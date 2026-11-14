import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../providers/creator_provider.dart';
import '../../../providers/workbench_provider.dart';
import '../../widgets/cyber_button.dart';
import '../../widgets/dropbox_image.dart';
import '../config/config_screen.dart';

class CreatorScreen extends StatefulWidget {
  const CreatorScreen({super.key});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _showSaveDialog() {
    _nameController.text =
        'Custom Kit #${DateTime.now().millisecondsSinceEpoch % 10000}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
        title: const Text(
          'ASSEMBLE AVATAR',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter kit designation to store in your Workbench tray:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final name = _nameController.text.trim();
              Navigator.of(ctx).pop();
              final creator = context.read<CreatorProvider>();
              final workbench = context.read<WorkbenchProvider>();
              final saved = await creator.saveCurrentKit(
                  name.isNotEmpty ? name : null);
              workbench.loadKits();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.surfaceElevated,
                    content: Text(
                      '${saved.name} ASSEMBLED AND STORED IN WORKBENCH',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }
            },
            child: const Text('STORE IN TRAY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )),
          ),
        ],
      ),
    );
  }

  void _showBackdropPicker() {
    final creator = context.read<CreatorProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.selectBackdrop,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: CreatorProvider.backdrops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final bd = CreatorProvider.backdrops[index];
                  final isSelected =
                      creator.selectedBackdropIndex == index;
                  return GestureDetector(
                    onTap: () {
                      creator.setBackdropIndex(index);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      width: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(bd[0]), Color(bd[1])],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.cyanAccent
                              : AppColors.surfaceBorder,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(Icons.check_rounded,
                                  color: AppColors.cyanAccent, size: 24),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final creator = context.watch<CreatorProvider>();
    final items = creator.currentCategoryItems;
    final backdropColors =
        CreatorProvider.backdrops[creator.selectedBackdropIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.unitCreator,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),

                  // Actions: Randomize & Backdrop
                  Row(
                    children: [
                      IconButton(
                        tooltip: AppStrings.selectBackdrop,
                        icon: const Icon(Icons.wallpaper_rounded,
                            color: AppColors.cyanAccent, size: 22),
                        onPressed: _showBackdropPicker,
                      ),
                      IconButton(
                        tooltip: AppStrings.autoFab,
                        icon: const Icon(Icons.shuffle_rounded,
                            color: AppColors.primaryLight, size: 22),
                        onPressed: () => creator.randomize(),
                      ),
                      IconButton(
                        tooltip: AppStrings.revert,
                        icon: const Icon(Icons.restart_alt_rounded,
                            color: AppColors.textMuted, size: 22),
                        onPressed: () => creator.resetToDefault(),
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.settings_outlined,
                            color: AppColors.textSecondary, size: 22),
                        onPressed: () => ConfigScreen.show(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gender Switcher: Boy / Girl
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    _buildGenderPill('BOY', 'Boy', creator),
                    _buildGenderPill('GIRL', 'Girl', creator),
                  ],
                ),
              ),
            ),

            // Multi-Layer Avatar Preview Canvas
            Expanded(
              flex: 5,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(backdropColors[0]),
                        Color(backdropColors[1]),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        // Sci-fi grid watermark
                        CustomPaint(
                          painter: _GridBackgroundPainter(),
                        ),

                        // Composite Layer Rendering in exact order
                        for (final cat in CreatorProvider.layerOrder)
                          if (creator.currentBuild[cat] != null &&
                              creator.currentBuild[cat]!.image.isNotEmpty)
                            DropboxImage(
                              key: ValueKey(creator.currentBuild[cat]!.image),
                              remotePath:
                                  '${ApiConstants.editorFolder}/${creator.currentBuild[cat]!.image}',
                              fit: BoxFit.contain,
                            ),

                        // ASSEMBLE Button floating at bottom
                        Positioned(
                          bottom: 14,
                          right: 14,
                          child: CyberButton(
                            height: 42,
                            text: AppStrings.assemble,
                            icon: Icons.check_circle_outline_rounded,
                            onPressed: _showSaveDialog,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Layer Category Horizontal Bar
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: CreatorProvider.layerOrder.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = CreatorProvider.layerOrder[index];
                  final isSelected = cat == creator.selectedCategory;
                  return GestureDetector(
                    onTap: () => creator.setCategory(cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.surfaceBorder,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat.toUpperCase(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Items Grid Palette for Selected Category
            Expanded(
              flex: 4,
              child: Builder(
                builder: (context) {
                  final isBody = creator.selectedCategory == 'Body';
                  final isOptional = [
                    'Accessories',
                    'Face',
                    'Shoes',
                    'Top',
                    'Bottom'
                  ].contains(creator.selectedCategory);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: AppColors.surfaceBorder,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category subheader
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isBody
                                    ? 'SKIN TONE // BODY CHASSIS'
                                    : '${creator.selectedCategory.toUpperCase()} MODULES',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Text(
                                '${items.length} ${isBody ? 'TONES' : 'ITEMS'}',
                                style: const TextStyle(
                                  color: AppColors.cyanAccent,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Grid
                        Expanded(
                          child: items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No items in this category',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  itemCount: isOptional
                                      ? items.length + 1
                                      : items.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.95,
                                  ),
                                  itemBuilder: (context, index) {
                                    if (isOptional && index == 0) {
                                      // "None" / Deselect slot for optional layers
                                      final isSelected = creator.currentBuild[
                                              creator.selectedCategory] ==
                                          null;
                                      return GestureDetector(
                                        onTap: () => creator.selectItem(
                                            creator.selectedCategory, null),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.2)
                                                : AppColors.surfaceElevated,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.cyanAccent
                                                  : AppColors.surfaceBorder,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.block_rounded,
                                                  color: AppColors.textMuted,
                                                  size: 22,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'NONE',
                                                  style: TextStyle(
                                                    color: AppColors.textMuted,
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.8,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    final itemIndex =
                                        isOptional ? index - 1 : index;
                                    final item = items[itemIndex];
                                    final isSelected = creator.currentBuild[
                                                creator.selectedCategory]
                                            ?.id ==
                                        item.id;

                                    // For Body, use full body mannequin item.image
                                    // For others, use icon preview item.preview
                                    final remotePath = isBody
                                        ? '${ApiConstants.editorFolder}/${item.image}'
                                        : '${ApiConstants.editorFolder}/${item.preview.isNotEmpty ? item.preview : item.image}';

                                    return GestureDetector(
                                      onTap: () => creator.selectItem(
                                          creator.selectedCategory, item),
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.primary
                                                      .withValues(alpha: 0.28)
                                                  : AppColors.surfaceElevated,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.cyanAccent
                                                    : AppColors.surfaceBorder,
                                                width: isSelected ? 2 : 1,
                                              ),
                                              boxShadow: isSelected
                                                  ? [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .cyanAccent
                                                            .withValues(
                                                                alpha: 0.35),
                                                        blurRadius: 8,
                                                      ),
                                                    ]
                                                  : null,
                                            ),
                                            padding: EdgeInsets.all(
                                                isBody ? 4 : 6),
                                            child: Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: DropboxImage(
                                                  remotePath: remotePath,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Body skin-tone color swatch dot in corner
                                          if (isBody &&
                                              item.preview.isNotEmpty)
                                            Positioned(
                                              bottom: 5,
                                              right: 5,
                                              child: Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.8),
                                                    width: 1.5,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(alpha: 0.5),
                                                      blurRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: DropboxImage(
                                                    remotePath:
                                                        '${ApiConstants.editorFolder}/${item.preview}',
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),

                                          // Selected checkmark indicator
                                          if (isSelected)
                                            Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Container(
                                                width: 18,
                                                height: 18,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.cyanAccent,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.check_rounded,
                                                    size: 12,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderPill(
      String label, String value, CreatorProvider creator) {
    final isSelected = creator.selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => creator.setGender(value),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
