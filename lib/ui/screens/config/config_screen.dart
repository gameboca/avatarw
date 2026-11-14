import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../providers/houses_provider.dart';
import '../../../providers/mods_provider.dart';
import '../../widgets/rate_us_dialog.dart';
import '../paywall_onboarding_screen.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ConfigScreen(),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SETTINGS',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'SYSTEM CONTROLS & TELEMETRY',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textPrimary, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.surfaceBorder, height: 1),

          // Options List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // VIP Forge Pass Subscription
                  _buildSettingTile(
                    icon: Icons.workspace_premium_rounded,
                    iconColor: AppColors.neonAmber,
                    title: 'VIP FORGE PASS',
                    subtitle: 'Manage \$9.99/week subscription & benefits',
                    onTap: () {
                      Navigator.of(context).pop();
                      PaywallOnboardingScreen.show(context);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Rate Us Banner
                  _buildSettingTile(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.neonAmber,
                    title: AppStrings.stampTheForge,
                    subtitle: AppStrings.verdictSubtitle,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => const RateUsDialog(),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Re-scan / Sync
                  _buildSettingTile(
                    icon: Icons.sync_rounded,
                    iconColor: AppColors.cyanAccent,
                    title: AppStrings.reScan,
                    subtitle: 'Re-index supply line modules from cloud forge',
                    onTap: () {
                      context.read<ModsProvider>().loadMods();
                      context.read<HousesProvider>().loadHouses();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.surfaceElevated,
                          content: const Text(
                            'SUPPLY LINE SYNCHRONIZED WITH CLOUD FORGE',
                            style: TextStyle(
                              color: AppColors.cyanAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Privacy Policy
                  _buildSettingTile(
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.primaryLight,
                    title: AppStrings.privacyPolicy,
                    subtitle: AppStrings.privacyPolicySub,
                    onTap: () => _openUrl(context, AppStrings.privacyUrl),
                  ),

                  const SizedBox(height: 12),

                  // Terms of Use
                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    iconColor: AppColors.primaryLight,
                    title: AppStrings.termsOfUse,
                    subtitle: AppStrings.termsOfUseSub,
                    onTap: () => _openUrl(context, AppStrings.termsUrl),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.surfaceBorder,
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
