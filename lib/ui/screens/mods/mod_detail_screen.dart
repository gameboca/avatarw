import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../models/mod_item.dart';
import '../../../providers/mods_provider.dart';
import '../../../services/dropbox_service.dart';
import '../../widgets/cyber_button.dart';
import '../../widgets/dropbox_image.dart';

class ModDetailScreen extends StatefulWidget {
  final ModItem mod;

  const ModDetailScreen({super.key, required this.mod});

  @override
  State<ModDetailScreen> createState() => _ModDetailScreenState();
}

class _ModDetailScreenState extends State<ModDetailScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  XFile? _downloadedFile;

  Future<void> _handleDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.05;
    });

    final remotePath =
        '${ApiConstants.modsFolder}/${widget.mod.filePath.isNotEmpty ? widget.mod.filePath : widget.mod.image}';

    final file = await DropboxService.instance.downloadToFile(
      remotePath,
      widget.mod.filePath.isNotEmpty
          ? widget.mod.filePath
          : 'mod_${widget.mod.id}.png',
      onProgress: (p) {
        setState(() {
          _downloadProgress = p;
        });
      },
    );

    setState(() {
      _isDownloading = false;
      _downloadedFile = file;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.surfaceBorder),
          ),
          backgroundColor: AppColors.surfaceElevated,
          content: Text(
            file != null
                ? AppStrings.deployComplete
                : AppStrings.deployFailed,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          action: file != null
              ? SnackBarAction(
                  label: 'SHARE',
                  textColor: AppColors.cyanAccent,
                  onPressed: () => Share.shareXFiles([file]),
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final modsProvider = context.watch<ModsProvider>();
    final isFav = widget.mod.isFavorite;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          AppStrings.specSheet,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: isFav ? AppColors.primaryLight : AppColors.textPrimary,
            ),
            onPressed: () => modsProvider.toggleFavorite(widget.mod),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Image Container with Cyber Frame
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1.25,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      DropboxImage(
                        remotePath:
                            '${ApiConstants.modsFolder}/${widget.mod.image}',
                        fit: BoxFit.cover,
                      ),
                      // Blueprint grid watermark
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.surfaceBorder,
                            ),
                          ),
                          child: const Text(
                            AppStrings.scale144,
                            style: TextStyle(
                              color: AppColors.cyanAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      if (widget.mod.isNew)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonPink,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              AppStrings.badgeNew,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Category & Unit tag
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Text(
                    widget.mod.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${AppStrings.badgeUnit} // ${widget.mod.id.substring(0, widget.mod.id.length > 8 ? 8 : widget.mod.id.length).toUpperCase()}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              widget.mod.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 12),

            // Description Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.surfaceBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terminal_rounded,
                          color: AppColors.cyanAccent, size: 16),
                      SizedBox(width: 8),
                      Text(
                        AppStrings.assemblyLog,
                        style: TextStyle(
                          color: AppColors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.mod.description.isNotEmpty
                        ? widget.mod.description
                        : 'No telemetry log provided for this module.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Download Progress Bar
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: AppColors.surfaceBorder,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.cyanAccent),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${AppStrings.assembling}... ${(_downloadProgress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.cyanAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            if (_downloadedFile != null) ...[
              CyberButton(
                text: 'SHARE ARTIFACT',
                icon: Icons.share_rounded,
                color: AppColors.cyanAccent,
                onPressed: () =>
                    Share.shareXFiles([_downloadedFile!]),
              ),
              const SizedBox(height: 12),
              CyberButton(
                text: AppStrings.retryDeploy,
                isOutlined: true,
                onPressed: _handleDownload,
              ),
            ] else ...[
              CyberButton(
                text: AppStrings.assemble,
                icon: Icons.download_rounded,
                isLoading: _isDownloading,
                onPressed: _handleDownload,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
