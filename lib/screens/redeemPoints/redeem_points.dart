import 'package:chumley_navigator/components/redeem_points/redeem_cards.dart';
import 'package:chumley_navigator/components/redeem_points/redeem_points_bottom_model.dart';
import 'package:chumley_navigator/models/points_model.dart';
import 'package:chumley_navigator/models/user_model.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/utils/number_display.dart';
import 'package:chumley_navigator/widgets/theme_scope.dart';
import 'package:chumley_navigator/widgets/ui/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RedeemPointsScreen extends StatefulWidget {
  const RedeemPointsScreen({super.key});

  @override
  State<RedeemPointsScreen> createState() => _RedeemPointsScreenState();
}

class _RedeemPointsScreenState extends State<RedeemPointsScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final user = args?['user'] as UserModel?;
    final performanceHistory = args?['performanceHistory'] as EngineerPerformanceHistory?;

    return ListenableBuilder(
      listenable: ThemeScope.of(context),
      builder: (context, _) {
        final theme = DashboardTheme.of(context);

        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your rewards journey',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: theme.text,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Earn points, unlock rewards',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _HeaderIconButton(
                        theme: theme,
                        icon: LucideIcons.clipboard_list,
                        onTap: () {
                          if (performanceHistory != null) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.90,
                                child: RedeemPointsBottomModal(performanceHistory: performanceHistory),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(width: 6.w),
                      _HeaderIconButton(
                        theme: theme,
                        icon: Icons.close,
                        onTap: () => Navigator.pop(context)
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AvailablePointsCard(
                          theme: theme,
                          user: user,
                          performanceHistory: performanceHistory,
                        ),
                        SizedBox(height: 10.h),
                        _RedeemCta(theme: theme),
                        RewardsJourneyList(scrollController: _scrollController),
                        _ClaimedRewards(theme: theme),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.theme,
    required this.icon,
    required this.onTap,
  });

  final DashboardTheme theme;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: theme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.border, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16.sp, color: theme.textMuted),
      ),
    );
  }
}

class _AvailablePointsCard extends StatefulWidget {
  const _AvailablePointsCard({
    required this.theme,
    required this.user,
    required this.performanceHistory,
  });

  final DashboardTheme theme;
  final UserModel? user;
  final EngineerPerformanceHistory? performanceHistory;

  @override
  State<_AvailablePointsCard> createState() => _AvailablePointsCardState();
}

class _AvailablePointsCardState extends State<_AvailablePointsCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _targetPoints = 0;

  @override
  void initState() {
    super.initState();
    _targetPoints = widget.performanceHistory?.cumulativeTotal ?? widget.user?.performanceScore.round() ?? 0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: _targetPoints.toDouble()).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AvailablePointsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTarget = widget.performanceHistory?.cumulativeTotal ?? widget.user?.performanceScore.round() ?? 0;
    if (newTarget != _targetPoints) {
      _targetPoints = newTarget;
      _animation = Tween<double>(
        begin: _animation.value,
        end: _targetPoints.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thisMonthPoints = widget.performanceHistory?.thisMonthTotal ?? 0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPoints = _animation.value.round();
        final currentPointsLabel = formatIntegerWithCommas(currentPoints);
        final thisMonthLabel =
            '${formatSignedIntegerWithCommas(thisMonthPoints)} this month';
        final progress = _targetPoints == 0 ? 1.0 : (_animation.value / _targetPoints).clamp(0.0, 1.0);

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 12.h, bottom: 10.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.primaryBlueDark,
              width: 0.5,
            ),
          ),
          child: Stack(
            children: [
              // SVG Background on the right side
              Positioned(
                right: -90.w,
                top: -36.h,
                child: Transform.rotate(
                  angle: 20 * 3.1415926535 / 180,
                  child: Opacity(
                    opacity: 0.3,
                    child: ClipRect(
                      clipper: _RevealClipper(progress),
                      child: CustomPaint(
                        size: Size(350.w, 274.w),
                        painter: _SvgBackgroundPainter(),
                      ),
                    ),
                  ),
                ),
              ),
              // Card Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 42.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE POINTS',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                        fontSize: 13.sp,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currentPointsLabel,
                          style: TextStyle(
                            fontSize: 48.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                            height: 1,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, bottom: 6.h),
                          child: Text(
                            'pts',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kpiBarHigh,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueDark,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: AppColors.textDarkBlue, width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14.sp,
                            color: AppColors.kpiBarHigh,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            thisMonthLabel,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.kpiBarHigh,
                            ),
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
      },
    );
  }
}

class _RevealClipper extends CustomClipper<Rect> {
  _RevealClipper(this.progress);

  final double progress;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * progress, size.height);
  }

  @override
  bool shouldReclip(covariant _RevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _SvgBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 62;
    final scaleY = size.height / 62;
    canvas.scale(scaleX, scaleY);

    final fillPaint = Paint()
      ..color = const Color(0xFFF1FF24)
      ..style = PaintingStyle.fill;

    // Path 2
    final path2 = Path()
      ..moveTo(8.38037, 10.7131)
      ..cubicTo(8.38037, 9.51566, 9.33634, 8.54492, 10.5156, 8.54492)
      ..lineTo(15.9654, 8.54492)
      ..cubicTo(16.5515, 8.54492, 17.033, 9.03383, 17.033, 9.62903)
      ..lineTo(17.033, 17.2178)
      ..cubicTo(17.033, 17.813, 16.5515, 18.3019, 15.9654, 18.3019)
      ..lineTo(10.5156, 18.3019)
      ..cubicTo(9.33634, 18.3019, 8.38037, 17.3312, 8.38037, 16.1337)
      ..lineTo(8.38037, 10.7131)
      ..close();
    canvas.drawPath(path2, fillPaint);

    // Path 3
    final path3 = Path()
      ..moveTo(8.38037, 23.4041)
      ..cubicTo(8.38037, 22.2066, 9.33634, 21.2358, 10.5156, 21.2358)
      ..lineTo(15.9654, 21.2358)
      ..cubicTo(16.5515, 21.2358, 17.033, 21.7248, 17.033, 22.32)
      ..lineTo(17.033, 29.9087)
      ..cubicTo(17.033, 30.511, 16.5515, 30.9928, 15.9654, 30.9928)
      ..lineTo(10.5156, 30.9928)
      ..cubicTo(9.33634, 30.9928, 8.38037, 30.0221, 8.38037, 28.8246)
      ..lineTo(8.38037, 23.4041)
      ..close();
    canvas.drawPath(path3, fillPaint);

    // Path 4
    final path4 = Path()
      ..moveTo(29.5304, 52.3562)
      ..cubicTo(29.5304, 52.9514, 29.0489, 53.4403, 28.4628, 53.4403)
      ..lineTo(10.5156, 53.4403)
      ..cubicTo(9.33634, 53.4403, 8.38037, 52.4695, 8.38037, 51.272)
      ..lineTo(8.38037, 47.8001)
      ..cubicTo(8.38037, 46.6026, 9.33634, 45.6318, 10.5156, 45.6318)
      ..lineTo(28.4558, 45.6318)
      ..cubicTo(29.0489, 45.6318, 29.5234, 46.1207, 29.5234, 46.7159)
      ..lineTo(29.5234, 52.3562)
      ..lineTo(29.5304, 52.3562)
      ..close();
    canvas.drawPath(path4, fillPaint);

    // Path 5
    final path5 = Path()
      ..moveTo(29.5304, 41.6213)
      ..cubicTo(29.5304, 42.2165, 29.0489, 42.7054, 28.4628, 42.7054)
      ..lineTo(10.5156, 42.7054)
      ..cubicTo(9.33634, 42.7054, 8.38037, 41.7347, 8.38037, 40.5372)
      ..lineTo(8.38037, 36.0945)
      ..cubicTo(8.38037, 34.897, 9.33634, 33.9263, 10.5156, 33.9263)
      ..lineTo(28.4558, 33.9263)
      ..cubicTo(29.0489, 33.9263, 29.5234, 34.4152, 29.5234, 35.0104)
      ..lineTo(29.5234, 41.6284)
      ..lineTo(29.5304, 41.6213)
      ..close();
    canvas.drawPath(path5, fillPaint);

    // Path 6
    final path6 = Path()
      ..moveTo(50.4844, 34.7124)
      ..lineTo(38.287, 52.5117)
      ..cubicTo(37.8893, 53.0927, 37.2333, 53.4399, 36.5356, 53.4399)
      ..lineTo(33.4792, 53.4399)
      ..cubicTo(32.8931, 53.4399, 32.4116, 52.951, 32.4116, 52.3558)
      ..lineTo(32.4116, 22.3195)
      ..cubicTo(32.4116, 21.7172, 31.9301, 21.2354, 31.344, 21.2354)
      ..lineTo(30.5973, 21.2354)
      ..cubicTo(30.0042, 21.2354, 29.5297, 21.7243, 29.5297, 22.3195)
      ..lineTo(29.5297, 28.8242)
      ..cubicTo(29.5297, 30.0217, 28.5738, 30.9924, 27.3945, 30.9924)
      ..lineTo(22.0564, 30.9924)
      ..cubicTo(20.8771, 30.9924, 19.9211, 30.0217, 19.9211, 28.8242)
      ..lineTo(19.9211, 9.62903)
      ..cubicTo(19.9211, 9.02675, 20.4026, 8.54492, 20.9888, 8.54492)
      ..lineTo(36.5425, 8.54492)
      ..cubicTo(37.2403, 8.54492, 37.8962, 8.89212, 38.294, 9.47315)
      ..lineTo(50.4844, 27.2724)
      ..cubicTo(52.0126, 29.5044, 52.0126, 32.4662, 50.4844, 34.7053);
    canvas.drawPath(path6, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SvgBackgroundPainter oldDelegate) => false;
}

class _RedeemCta extends StatelessWidget {
  const _RedeemCta({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () {},
      scale: 0.98,
      child: Container(
        width: double.infinity,
        height: 40.h,
        margin: EdgeInsets.only(bottom: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard, size: 16.sp, color: AppColors.white),
            SizedBox(width: 6.w),
            Text(
              'Redeem points',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimedRewards extends StatelessWidget {
  const _ClaimedRewards({required this.theme});

  final DashboardTheme theme;

  static final _data = [
    (
      image: 'assets/brands/tesco.png',
      reward: 'Tesco',
      amount: '£10',
      pts: '1,000',
      redeemDate: '12 Apr 2026',
      backgroundColor: AppColors.giftCardNhsBg,
    ),
    (
      image: 'assets/brands/costa.png',
      reward: 'Costa Coffee',
      amount: '£5',
      pts: '500',
      redeemDate: '02 Mar 2026',
      backgroundColor: AppColors.giftCardTargetBg,
    ),
    (
      image: 'assets/brands/amazon.png',
      reward: 'Amazon.co.uk',
      amount: '£15',
      pts: '1,500',
      redeemDate: '18 Feb 2026',
      backgroundColor: AppColors.giftCardAmazonBg,
    ),
    (
      image: 'assets/brands/sainsburys.png',
      reward: "Sainsbury's",
      amount: '£20',
      pts: '2,000',
      redeemDate: '05 Jan 2026',
      backgroundColor: AppColors.giftCardSainsburysBg,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Text(
          'CLAIMED REWARDS',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
            letterSpacing: 0.4,
            color: theme.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            border: Border.all(color: theme.border, width: 0.5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          clipBehavior: Clip.hardEdge,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _data.length,
            separatorBuilder: (_, __) => Divider(
              height: 0,
              thickness: 0.5,
              color: theme.border,
            ),
            itemBuilder: (_, index) {
              final item = _data[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    _BrandCard(
                      imagePath: item.image,
                      amount: item.amount,
                      backgroundColor: item.backgroundColor,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.reward} ${item.amount}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: theme.text,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Redeemed · ${item.redeemDate}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '−${item.pts} pts',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: theme.textMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.imagePath,
    required this.amount,
    required this.backgroundColor,
  });

  final String imagePath;
  final String amount;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72.w,
      height: 48.h,
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            imagePath,
            height: 14.h,
            fit: BoxFit.contain,
            color: AppColors.white,
            colorBlendMode: BlendMode.srcIn,
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
