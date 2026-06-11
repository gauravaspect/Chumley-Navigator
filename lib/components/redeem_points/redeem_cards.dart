import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

enum RewardStatus { available, locked }

class RewardItem {
  const RewardItem({
    required this.image,
    required this.name,
    required this.amount,
    required this.subtitle,
    required this.pts,
    required this.ptsToGo,
    required this.bgColor,
    required this.status,
    this.progress = 0.0,
    this.amountColor = Colors.white,
  });

  final String image;
  final String name;
  final String amount;
  final String subtitle;
  final int pts;
  final int ptsToGo;
  final Color bgColor;
  final RewardStatus status;
  final double progress;
  final Color amountColor;
}

const _rewards = [
  RewardItem(
    image: 'assets/brands/costa.png',
    name: 'Costa Coffee',
    amount: '£5',
    subtitle: 'Hot drinks on the go',
    pts: 500,
    ptsToGo: 500,
    bgColor: AppColors.giftCardTargetBg,
    status: RewardStatus.available,
    progress: 0.0,
  ),
  RewardItem(
    image: 'assets/brands/tesco.png',
    name: 'Tesco',
    amount: '£10',
    subtitle: 'Weekly shop · Clubcard partner',
    pts: 1000,
    ptsToGo: 1000,
    bgColor: AppColors.giftCardNhsBg,
    status: RewardStatus.available,
    progress: 0.0,
  ),
  RewardItem(
    image: 'assets/brands/amazon.png',
    name: 'Amazon.co.uk',
    amount: '£15',
    subtitle: 'Anything you need, fast',
    pts: 1500,
    ptsToGo: 0,
    bgColor: AppColors.giftCardAmazonBg,
    status: RewardStatus.locked,
    amountColor: AppColors.giftCardAmazonAmount,
  ),
  RewardItem(
    image: 'assets/brands/sainsburys.png',
    name: "Sainsbury's",
    amount: '£20',
    subtitle: 'Food, fuel & Argos in store',
    pts: 2000,
    ptsToGo: 0,
    bgColor: AppColors.giftCardSainsburysBg,
    status: RewardStatus.locked,
  ),
  RewardItem(
    image: 'assets/brands/currys.png',
    name: 'Currys',
    amount: '£25',
    subtitle: 'Tech, appliances & gaming',
    pts: 2500,
    ptsToGo: 0,
    bgColor: AppColors.giftCardMorrisonsBg,
    status: RewardStatus.locked,
  ),
  RewardItem(
    image: 'assets/brands/shell.png',
    name: 'Shell',
    amount: '£50',
    subtitle: 'Fuel & convenience',
    pts: 5000,
    ptsToGo: 0,
    bgColor: AppColors.giftCardMcdonaldsBg,
    status: RewardStatus.locked,
    amountColor: AppColors.giftCardMcdonaldsAmount,
  ),
];

// ── Main Widget ───────────────────────────────────────────────────────────────

class RewardsJourneyList extends StatefulWidget {
  const RewardsJourneyList({super.key, this.scrollController});

  final ScrollController? scrollController;

  @override
  State<RewardsJourneyList> createState() => _RewardsJourneyListState();
}

class _RewardsJourneyListState extends State<RewardsJourneyList> {

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GIFT CARDS',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
              letterSpacing: 0.4,
              color: theme.textMuted,
            ),
          ),
          Text(
            '0 ready · 2 almost there · 4 locked',
            style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
          ),
          SizedBox(height: 12.h),
          if (widget.scrollController == null)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _rewards.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _rewardCard(theme: theme, item: _rewards[i]),
              ),
            )
          else
            AnimatedBuilder(
              animation: widget.scrollController!,
              builder: (context, _) {
                final double scrollOffset = widget.scrollController!.hasClients
                    ? widget.scrollController!.offset
                    : 0.0;

                final double cardHeight = 246.h;
                final double spacing = 12.h;
                final double pinSpacing = 36.h;
                final double listTopOffset = 269.h;
                final double totalHeight = _rewards.length * cardHeight + (_rewards.length - 1) * spacing;

                return SizedBox(
                  height: totalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(_rewards.length, (i) {
                      final double normalTop = i * (cardHeight + spacing);
                      final double viewportTopNormal = listTopOffset + normalTop - scrollOffset;

                      final double pinnedViewportTop = i * pinSpacing;
                      final double limitViewportTop = listTopOffset + totalHeight - cardHeight - scrollOffset;
                      final double clampedViewportTop = pinnedViewportTop < limitViewportTop ? pinnedViewportTop : limitViewportTop;

                      final double finalViewportTop = viewportTopNormal > clampedViewportTop ? viewportTopNormal : clampedViewportTop;
                      final double finalLocalTop = finalViewportTop - listTopOffset + scrollOffset;

                      return Positioned(
                        top: finalLocalTop,
                        left: 0,
                        right: 0,
                        height: cardHeight,
                        child: _rewardCard(theme: theme, item: _rewards[i]),
                      );
                    }),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ── Reward card ────────────────────────────────────────────────────────────

  Widget _rewardCard({
    required DashboardTheme theme,
    required RewardItem item,
  }) {
    final isLocked = item.status == RewardStatus.locked;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border.all(
          color: isLocked ? theme.border : theme.accent,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand image card
          _brandImageCard(item: item, isLocked: isLocked),

          SizedBox(height: 8.h),

          // Status badge
          _statusBadge(theme: theme, item: item, isLocked: isLocked),

          SizedBox(height: 6.h),

          // Title + points row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.name} ${item.amount}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.text,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.normal,
                        color: theme.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.pts}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.textMuted,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'pts',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: theme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Progress bar (available only)
          if (!isLocked) ...[
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: SizedBox(
                height: 6.h,
                child: LinearProgressIndicator(
                  value: item.progress,
                  backgroundColor: theme.progressTrack,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Brand image card ───────────────────────────────────────────────────────

  Widget _brandImageCard({required RewardItem item, required bool isLocked}) {
    Widget card = AspectRatio(
      aspectRatio: 2.15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          color: item.bgColor,
          child: Stack(
            children: [
              // Gradient shimmer overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.18),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.10),
                      ],
                      stops: const [0.0, 0.45, 0.70, 1.0],
                    ),
                  ),
                ),
              ),

              // Gold chip
              Positioned(
                right: 12.w,
                top: 12.h,
                child: Opacity(
                  opacity: 0.8,
                  child: Container(
                    width: 28.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.cardShineStart, AppColors.cardShineEnd],
                      ),
                    ),
                  ),
                ),
              ),

              // Logo + label + amount
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 120.w),
                        child: Image.asset(
                          item.image,
                          height: 32.h,
                          fit: BoxFit.contain,
                          color: Colors.white,
                          colorBlendMode: BlendMode.srcIn,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GIFT CARD',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.white.withOpacity(0.70),
                              letterSpacing: 0.9,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.amount,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: item.amountColor,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isLocked) {
      card = Opacity(
        opacity: 0.75,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.4441, 0.5001, 0.0505, 0, 0,
            0.1486, 0.7510, 0.0761, 0, 0,
            0.1486, 0.5001, 0.2360, 0, 0,
            0,      0,      0,      1, 0,
          ]),
          child: card,
        ),
      );
    }

    return card;
  }

  // ── Status badge ───────────────────────────────────────────────────────────

  Widget _statusBadge({
    required DashboardTheme theme,
    required RewardItem item,
    required bool isLocked,
  }) {
    if (isLocked) {
      return _badge(
        bgColor: theme.surfaceDeep,
        borderColor: theme.border,
        icon: Icon(Icons.lock_rounded, size: 11.sp, color: theme.textMuted),
        label: 'Locked',
        labelColor: theme.textMuted,
      );
    }

    return _badge(
      bgColor: AppColors.pendingBackground,
      borderColor: AppColors.pendingText.withValues(alpha: 0.25),
      icon: Icon(Icons.access_time_rounded, size: 11.sp, color: AppColors.pendingText),
      label: '${item.ptsToGo} pts to go',
      labelColor: AppColors.pendingText,
    );
  }

  // ── Badge ──────────────────────────────────────────────────────────────────

  Widget _badge({
    required Color bgColor,
    required Color borderColor,
    required Widget icon,
    required String label,
    required Color labelColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: 4.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: labelColor,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}