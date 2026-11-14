import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/assembled_avatar.dart';
import '../../../providers/creator_provider.dart';
import '../../../providers/workbench_provider.dart';
import '../../widgets/cyber_button.dart';
import '../../widgets/dropbox_image.dart';
import '../config/config_screen.dart';

class WorkbenchScreen extends StatelessWidget {
  final Function(int) onTabSwitch;

  const WorkbenchScreen({super.key, required this.onTabSwitch});

  void _confirmDisassemble(BuildContext context, AssembledAvatar kit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.neonPink, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.neonPink, size: 24),
            SizedBox(width: 8),
            Text(
              AppStrings.disassembleKitQ,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        content: Text(
          '${AppStrings.teardownPermanent}\n\nKit: "${kit.name}"',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              AppStrings.keep,
              style: TextStyle(
                color: AppColors.cyanAccent,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonPink,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<WorkbenchProvider>().disassembleKit(kit.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.surfaceElevated,
                  content: Text(
                    'KIT DISASSEMBLED AND REMOVED FROM TRAY',
                    style: TextStyle(color: AppColors.neonPink),
                  ),
                ),
              );
            },
            child: const Text(
              AppStrings.disassemble,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workbench = context.watch<WorkbenchProvider>();
    final kits = workbench.kits;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              AppStrings.workbench,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'TRAY // 03 · ${kits.length} ASSEMBLED KITS',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined,
                              color: AppColors.textSecondary, size: 22),
                          onPressed: () => ConfigScreen.show(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CyberButton(
                            height: 48,
                            text: AppStrings.assembleAvatar,
                            icon: Icons.add_circle_outline_rounded,
                            onPressed: () {
                              context.read<CreatorProvider>().resetToDefault();
                              onTabSwitch(3); // Creator tab
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CyberButton(
                            height: 48,
                            text: AppStrings.autoFab,
                            icon: Icons.auto_awesome_rounded,
                            isOutlined: true,
                            onPressed: () {
                              context.read<CreatorProvider>().randomize();
                              onTabSwitch(3);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),

            // Empty state or Grid of Kits
            if (kits.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.build_circle_outlined,
                          size: 64,
                          color: AppColors.textMuted.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppStrings.noKitsTitle,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          AppStrings.noKitsSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
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
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final kit = kits[index];
                      final dateFormatted =
                          DateFormat('MMM d, yyyy · HH:mm')
                              .format(kit.createdAt);

                      final backdropIdx =
                          int.tryParse(kit.backdrop) ?? 0;
                      final bdColors = CreatorProvider
                          .backdrops[backdropIdx % CreatorProvider.backdrops.length];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.surfaceBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Preview box with composite layers
                            Container(
                              width: 120,
                              height: 140,
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(bdColors[0]),
                                    Color(bdColors[1]),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    for (final cat in CreatorProvider.layerOrder)
                                      if (kit.selectedLayers[cat] != null &&
                                          kit.selectedLayers[cat]!.isNotEmpty)
                                        DropboxImage(
                                          remotePath:
                                              '${ApiConstants.editorFolder}/${kit.selectedLayers[cat]!}',
                                          fit: BoxFit.contain,
                                        ),
                                  ],
                                ),
                              ),
                            ),

                            // Kit Info & Actions
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0, 12, 14, 12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        kit.gender.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.primaryLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      kit.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormatted,
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 34,
                                            child: ElevatedButton(
                                              style:
                                                  ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.surfaceElevated,
                                                padding: EdgeInsets.zero,
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8),
                                                  side: const BorderSide(
                                                    color: AppColors
                                                        .primaryLight,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<CreatorProvider>()
                                                    .loadFromKit(kit);
                                                onTabSwitch(3);
                                              },
                                              child: const Text(
                                                AppStrings.modify,
                                                style: TextStyle(
                                                  color: AppColors
                                                      .primaryLight,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          iconSize: 20,
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.neonPink,
                                          ),
                                          onPressed: () =>
                                              _confirmDisassemble(
                                                  context, kit),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: kits.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
