import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens sampled from the supplied Sign In mock.
///
/// Kept as a single source of truth so the rest of the app can reference
/// [AppColors] / [AppTextStyles] without hard-coding literals inline.
class AppColors {
  AppColors._();

  /// Near-black header / footer band.
  static const Color backgroundDark = Color(0xFF0B1220);

  /// Deep navy hero card behind the "Sign In" title.
  static const Color cardNavy = Color(0xFF0F2A5B);

  /// Page background behind the white card on wider viewports.
  static const Color pageBackground = Color(0xFFF4F5F7);

  /// White surface for the form area.
  static const Color surface = Color(0xFFFFFFFF);

  /// Filled input background.
  static const Color inputFill = Color(0xFFE5E9EF);

  /// Outlined social button border.
  static const Color outlineBorder = Color(0xFFE2E5EB);

  /// Muted grey text (labels, secondary copy).
  static const Color mutedText = Color(0xFF6B7688);

  /// Primary CTA yellow.
  static const Color primary = Color(0xFFF5C64C);

  /// Deep navy CTA used on the Create Account button (matches the
  /// real eTalente sign-up page). Darker than [cardNavy] for contrast
  /// against white.
  static const Color navyAction = Color(0xFF0A2A5E);

  /// Thin grey border used on the sign-up page's outlined fields.
  static const Color fieldBorder = Color(0xFFD9DCE2);

  /// Accent blue used for "Terms" / "Privacy Policy" / "Log In" links.
  static const Color linkBlue = Color(0xFF1A73E8);

  /// Body text on white.
  static const Color onSurface = Color(0xFF111827);

  /// Subtle white grid overlay on the navy hero card.
  static const Color gridOverlay = Color(0x1FFFFFFF);

  // ---------------------------------------------------------------
  // Job Board (dashboard) palette
  // ---------------------------------------------------------------

  /// Left sidebar on the Job Board — slightly darker than [cardNavy].
  static const Color sidebarNavy = Color(0xFF0B1E46);

  /// Right-rail Quick Stats card background.
  static const Color statsCardNavy = Color(0xFF11234D);

  /// Light neutral for the job-board page behind white cards.
  static const Color dashboardSurface = Color(0xFFF1F3F6);

  /// Soft grey tile behind the icon on each job card.
  static const Color jobIconTile = Color(0xFFEDF0F4);

  /// Blue pill used for "Full-time" tags.
  static const Color tagFullTimeBg = Color(0xFFDCEBFB);
  static const Color tagFullTimeFg = Color(0xFF1C74C4);

  /// Green pill used for "Contract" tags.
  static const Color tagContractBg = Color(0xFFDDF4E4);
  static const Color tagContractFg = Color(0xFF1F8E4A);

  /// Amber pill used for "Internship" tags.
  static const Color tagInternshipBg = Color(0xFFFDEFD1);
  static const Color tagInternshipFg = Color(0xFFAC7D10);

  /// Red accent used for the closing date on the highlighted job.
  static const Color closingSoon = Color(0xFFDB3A3A);

  /// Yellow accent used for the filled bookmark / featured star.
  static const Color accentYellow = Color(0xFFF5C64C);

  /// Faint grey for card borders / dividers.
  static const Color softDivider = Color(0xFFE5E8EE);

  /// Chatbot Assistant card background.
  static const Color chatbotCardBg = Color(0xFFFBECC6);
}

/// Centralised text styles. Uses Inter (via google_fonts) to match the
/// geometric sans in the mock. If the host is offline, google_fonts
/// gracefully falls back to the system default so the app still renders.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heroTitle = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.1,
  );

  static TextStyle heroSubtitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.85),
    letterSpacing: 2.4,
  );

  static TextStyle fieldLabel = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.mutedText,
    letterSpacing: 1.2,
  );

  static TextStyle inputText = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle inputHint = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
  );

  static TextStyle primaryButton = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
    letterSpacing: 1.6,
  );

  static TextStyle socialButton = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle orDivider = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.mutedText,
    letterSpacing: 1.6,
  );

  static TextStyle linkStrong = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMuted = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
  );

  static TextStyle footerBody = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.white.withValues(alpha: 0.75),
    height: 1.4,
  );

  static TextStyle footerLink = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.85),
  );

  static TextStyle logoWordmark = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 1.4,
  );

  static TextStyle trustBadge = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.mutedText,
    letterSpacing: 1.2,
  );

  /// Large centred title used on the sign-up card — navy, bold.
  static TextStyle sectionTitle = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.navyAction,
  );

  /// eTalente wordmark in dark navy (white card variant used on the
  /// sign-up page).
  static TextStyle logoWordmarkNavy = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.navyAction,
    letterSpacing: 0.4,
  );

  /// Label floated above the outlined sign-up fields.
  static TextStyle floatingLabel = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
  );

  /// White-text CTA label (Create Account).
  static TextStyle navyButton = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  /// Terms agreement sentence (body) on white.
  static TextStyle termsBody = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
  );

  /// Inline blue link inside the terms sentence.
  static TextStyle termsLink = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.linkBlue,
  );

  // ---------------------------------------------------------------
  // Job Board typography
  // ---------------------------------------------------------------

  /// Large "Job Board" page title.
  static TextStyle pageTitle = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
    height: 1.1,
  );

  /// Muted subtitle under the page title.
  static TextStyle pageSubtitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
    height: 1.4,
  );

  /// Job card title.
  static TextStyle jobTitle = GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  /// Inline meta row (location, company) on a job card.
  static TextStyle jobMeta = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.mutedText,
  );

  /// "EXPERIENCE" / "SALARY RANGE" column headers.
  static TextStyle jobStatLabel = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.mutedText,
    letterSpacing: 1.2,
  );

  /// Column values under the stat labels.
  static TextStyle jobStatValue = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  /// Filter pill label (inactive).
  static TextStyle pillInactive = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  /// Filter pill label on the selected "All Filters" pill.
  static TextStyle pillActive = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  /// Sidebar nav label (inactive, white-on-navy).
  static TextStyle sidebarItem = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.82),
  );

  /// Sidebar nav label (active — black on yellow pill).
  static TextStyle sidebarItemActive = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  /// Section title on the Quick Stats / Featured Talent / Chatbot cards.
  static TextStyle cardSectionTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  /// Same, but inverted for navy cards.
  static TextStyle cardSectionTitleInverse = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.accentYellow,
  );

  /// Stat label on the Quick Stats card.
  static TextStyle statsLabel = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: Colors.white.withValues(alpha: 0.85),
  );

  /// Stat value on the Quick Stats card.
  static TextStyle statsValue = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
}

/// Assembles the global [ThemeData]. Keeps widget code free of repeated
/// theming boilerplate.
ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.pageBackground,
    textTheme: GoogleFonts.interTextTheme(),
  );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      hintStyle: AppTextStyles.inputHint,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    ),
  );
}
