import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({super.key, required this.theme, required this.onClose});

  final DashboardTheme theme;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlueDark,
            AppColors.accentBlue,
          ],
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              'assets/images/nav_logo.png',
              width: 36.w,
              height: 36.w,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  LucideIcons.compass,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Chumley Navigator',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9.r),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(9.r),
              child: SizedBox(
                width: 32.w,
                height: 32.w,
                child: Icon(LucideIcons.x, color: Colors.white, size: 16.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatTabBar extends StatelessWidget {
  const ChatTabBar({
    super.key,
    required this.theme,
    required this.activeTab,
    required this.showChats,
    required this.unreadTotal,
    required this.onTabSelected,
  });

  final DashboardTheme theme;
  final ChumleyPanelTab activeTab;
  final bool showChats;
  final int unreadTotal;
  final ValueChanged<ChumleyPanelTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final tabs = <(ChumleyPanelTab, String, IconData)>[
      if (showChats) (ChumleyPanelTab.chats, 'Chats', LucideIcons.users),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(bottom: BorderSide(color: theme.border, width: 0.5)),
      ),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: theme.dashChipBg,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: theme.dashBorderLight, width: 0.5),
        ),
        child: Row(
          children: [
            for (final (tab, label, icon) in tabs)
              Expanded(
                child: Material(
                  color: activeTab == tab
                      ? AppColors.primaryBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999.r),
                  child: InkWell(
                    onTap: () => onTabSelected(tab),
                    borderRadius: BorderRadius.circular(999.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 9.h,
                        horizontal: 4.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icon,
                            size: 15.sp,
                            color: activeTab == tab
                                ? Colors.white
                                : theme.textMuted,
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: activeTab == tab
                                    ? Colors.white
                                    : theme.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (tab == ChumleyPanelTab.chats &&
                              unreadTotal > 0) ...[
                            SizedBox(width: 4.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color: activeTab == tab
                                    ? Colors.white
                                    : AppColors.streakOrange,
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                unreadTotal > 99 ? '99+' : '$unreadTotal',
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: activeTab == tab
                                      ? AppColors.primaryBlue
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatFooter extends StatelessWidget {
  const ChatFooter({super.key, required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      decoration: BoxDecoration(
        color: theme.surface,
        border: Border(top: BorderSide(color: theme.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Powered by',
            style: TextStyle(fontSize: 9.sp, color: theme.textMuted),
          ),
          SizedBox(width: 5.w),
          Image.asset(
            'assets/images/chumleyLogoNew.png',
            height: 14.h,
            errorBuilder: (_, _, _) => Text(
              'Chumley',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: theme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
