import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/revenue_cat_service.dart';
import '../../services/storage_service.dart';
import '../widgets/cyber_button.dart';
import 'main_shell_screen.dart';

class PaywallOnboardingScreen extends StatefulWidget {
  final bool isModal;

  const PaywallOnboardingScreen({super.key, this.isModal = false});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const PaywallOnboardingScreen(isModal: true),
      ),
    );
  }

  @override
  State<PaywallOnboardingScreen> createState() =>
      _PaywallOnboardingScreenState();
}

class _PaywallOnboardingScreenState extends State<PaywallOnboardingScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initVideo();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
          'assets/videos/cinderveil_pulse_reel.mp4');
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.play();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _dismissPaywall() async {
    await StorageService.instance.setOnboardingDone(true);
    if (!mounted) return;

    if (widget.isModal) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    }
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);

    final success =
        await RevenueCatService.instance.purchaseWeekly();

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surfaceElevated,
            content: Text(
              '🎉 WELCOME TO VIP FORGE PASS! ACCESS UNLOCKED.',
              style: TextStyle(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
        _dismissPaywall();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.surfaceElevated,
            content: Text(
              'Purchase was cancelled or could not be verified.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    final restored = await RevenueCatService.instance.restorePurchases();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceElevated,
          content: Text(
            restored
                ? 'Your VIP Forge Pass has been restored!'
                : 'No previous active subscription found.',
            style: TextStyle(
              color: restored ? AppColors.neonGreen : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      if (restored) _dismissPaywall();
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Video with dark overlay
          if (_videoController != null && _videoController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),

          // Deep Dark Glassmorphism Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  AppColors.background.withValues(alpha: 0.88),
                  AppColors.background.withValues(alpha: 0.98),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 0.85],
              ),
            ),
          ),

          // Content Scroll
          SafeArea(
            child: Column(
              children: [
                // Top Bar: Close (✕) and Restore
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textPrimary, size: 24),
                          onPressed: _dismissPaywall,
                        ),
                      ),
                      TextButton(
                        onPressed: _handleRestore,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'RESTORE',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),

                        // Glowing VIP Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFB300)
                                    .withValues(alpha: 0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium_rounded,
                                  color: Colors.black, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'VIP FORGE PASS',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Headline
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.white, Color(0xFFD6B0FF)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: const Text(
                            'UNLIMITED ACCESS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              height: 1.15,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Unlock All 120+ Mods, Mansions & Character Studio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Social Proof Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.surfaceBorder,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⭐️⭐️⭐️⭐️⭐️',
                                  style: TextStyle(fontSize: 11)),
                              SizedBox(width: 6),
                              Text(
                                '4.9 · Loved by 250,000+ Creators',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // VIP Feature Checklist
                        _buildFeatureRow(
                          icon: Icons.rocket_launch_rounded,
                          iconColor: AppColors.neonPink,
                          title: '120+ Exclusive Modpacks & Vehicles',
                          subtitle: 'Turbo cars, secrets, weapon packs & items',
                        ),
                        _buildFeatureRow(
                          icon: Icons.castle_rounded,
                          iconColor: AppColors.cyanAccent,
                          title: 'All Mansions & Luxury Interiors',
                          subtitle: 'Full blueprints & aesthetic room designs',
                        ),
                        _buildFeatureRow(
                          icon: Icons.palette_rounded,
                          iconColor: AppColors.primaryLight,
                          title: '10-Layer Character Studio Unlocked',
                          subtitle: 'Unlimited outfit pieces, hairstyles & faces',
                        ),
                        _buildFeatureRow(
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.neonAmber,
                          title: 'Weekly Cloud Forge Drops',
                          subtitle: 'Fresh arrivals updated over-the-air',
                        ),
                        _buildFeatureRow(
                          icon: Icons.block_rounded,
                          iconColor: AppColors.neonGreen,
                          title: '100% Ad-Free & Offline Ready',
                          subtitle: 'Zero wait times, full unlimited experience',
                        ),

                        const SizedBox(height: 20),

                        // Single Weekly VIP Plan ($9.99/week with 3-Day Free Trial)
                        _buildWeeklyPlanCard(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom Floating CTA Bar
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(
                          color: AppColors.surfaceBorder, width: 1.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: CyberButton(
                          height: 56,
                          text: 'START 3-DAY FREE TRIAL',
                          icon: Icons.bolt_rounded,
                          isLoading: _isLoading,
                          onPressed: _handlePurchase,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No payment due today · Cancel anytime in Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Legal Links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _openUrl(AppStrings.termsUrl),
                            child: const Text(
                              'Terms of Use',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('·',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                          GestureDetector(
                            onTap: _handleRestore,
                            child: const Text(
                              'Restore',
                              style: TextStyle(
                                color: AppColors.cyanAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('·',
                                style: TextStyle(color: AppColors.textMuted)),
                          ),
                          GestureDetector(
                            onTap: () => _openUrl(AppStrings.privacyUrl),
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
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
        ],
      ),
    );
  }

  Widget _buildWeeklyPlanCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.32),
                AppColors.surfaceElevated,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryLight,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Check indicator
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded,
                      size: 15, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),

              // Title & Subtitle
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY VIP PASS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '3-Day Free Trial, then \$9.99/week\nCancel anytime in Settings',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              // Price
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$9.99',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '/ week',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating Badge
        Positioned(
          top: -10,
          right: 14,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.neonPink, Color(0xFFFF529A)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPink.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'MOST POPULAR · 3 DAYS FREE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
