import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';

class FestiveCountdownBanner extends StatefulWidget {
  final DateTime? pujaDate;

  const FestiveCountdownBanner({
    super.key,
    this.pujaDate,
  });

  @override
  State<FestiveCountdownBanner> createState() => _FestiveCountdownBannerState();
}

class _FestiveCountdownBannerState extends State<FestiveCountdownBanner> {
  late Timer _timer;
  late Duration _timeRemaining;

  // Durga Puja 2026 Maha Shasthi target date (Default: October 16, 2026)
  late final DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    _targetDate = widget.pujaDate ?? DateTime(2026, 10, 16, 6, 0, 0);
    _calculateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _calculateRemainingTime();
      }
    });
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final difference = _targetDate.difference(now);
    setState(() {
      _timeRemaining = difference.isNegative ? Duration.zero : difference;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            Color(0xFF8B2635),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Background Decorative Circles & Motifs
            Positioned(
              right: -24,
              bottom: -24,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              left: -30,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Greeting & Subtitle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '🪔',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'SHUBHO SHARADIYA',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                          color: AppColors.accentLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '🪔',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Durga Puja Countdown 2026',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Timer Grid / Pills
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimerPill(days.toString().padLeft(2, '0'), 'DAYS'),
                      _buildSeparator(),
                      _buildTimerPill(hours.toString().padLeft(2, '0'), 'HOURS'),
                      _buildSeparator(),
                      _buildTimerPill(minutes.toString().padLeft(2, '0'), 'MINS'),
                      _buildSeparator(),
                      _buildTimerPill(seconds.toString().padLeft(2, '0'), 'SECS'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerPill(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.accentLight,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.accentLight.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
