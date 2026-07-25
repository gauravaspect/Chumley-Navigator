import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_cubit.dart';
import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_state.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:chumley_navigator/widgets/ui/elevated_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Chumley Navigator AI panel — Insights, AI Chat, and people Chats.
class ChumleyChatScreen extends StatefulWidget {
  const ChumleyChatScreen({super.key});

  @override
  State<ChumleyChatScreen> createState() => _ChumleyChatScreenState();
}

class _ChumleyChatScreenState extends State<ChumleyChatScreen>
    with WidgetsBindingObserver {
  final _aiInputController = TextEditingController();
  final _chumleyInputController = TextEditingController();
  final _dmEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _aiInputController.dispose();
    _chumleyInputController.dispose();
    _dmEmailController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ChumleyChatCubit>().onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DashboardTheme.of(context);

    return BlocBuilder<ChumleyChatCubit, ChumleyChatState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.base,
          body: SafeArea(
            child: Column(
              children: [
                _Header(
                  theme: theme,
                  onClose: () => Navigator.maybePop(context),
                ),
                _TabBar(
                  theme: theme,
                  activeTab: state.activeTab,
                  showChats: true,
                  unreadTotal: state.unreadTotal,
                  onTabSelected: (tab) =>
                      context.read<ChumleyChatCubit>().selectTab(tab),
                ),
                Expanded(
                  child: switch (state.activeTab) {
                    // ChumleyPanelTab.insights => _InsightsTab(
                    //     theme: theme,
                    //     state: state,
                    //     onRetry: () =>
                    //         context.read<ChumleyChatCubit>().loadBriefing(),
                    //   ),
                    // ChumleyPanelTab.aiChat => _AiChatTab(
                    //     theme: theme,
                    //     state: state,
                    //     inputController: _aiInputController,
                    //   ),
                    ChumleyPanelTab.insights ||
                    ChumleyPanelTab.aiChat ||
                    ChumleyPanelTab.chats =>
                      _ChatsTab(
                        theme: theme,
                        state: state,
                        inputController: _chumleyInputController,
                        dmEmailController: _dmEmailController,
                      ),
                  },
                ),
                _Footer(theme: theme),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header / tabs / footer ───────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.onClose});

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
                child: Icon(LucideIcons.compass, color: Colors.white, size: 20.sp),
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

class _TabBar extends StatelessWidget {
  const _TabBar({
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
      // (ChumleyPanelTab.insights, 'Insights', LucideIcons.chartLine),
      // (ChumleyPanelTab.aiChat, 'AI Chat', LucideIcons.sparkles),
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
                      padding:
                          EdgeInsets.symmetric(vertical: 9.h, horizontal: 4.w),
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
                          if (tab == ChumleyPanelTab.chats && unreadTotal > 0) ...[
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

class _Footer extends StatelessWidget {
  const _Footer({required this.theme});

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

// ── Insights ─────────────────────────────────────────────────────────────────

class _InsightsTab extends StatelessWidget {
  const _InsightsTab({
    required this.theme,
    required this.state,
    required this.onRetry,
  });

  final DashboardTheme theme;
  final ChumleyChatState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.briefingLoading && state.briefing == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.briefingError != null && state.briefing == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.briefingError!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.errorText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final briefing = state.briefing;
    if (briefing == null) {
      return Center(
        child: Text(
          'No briefing available.',
          style: TextStyle(color: theme.textMuted, fontSize: 13.sp),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 22.h),
      children: [
        Text(
          '${briefing.areaCount} AREAS',
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: theme.textMuted,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          "Today's headlines",
          style: TextStyle(
            fontSize: 21.sp,
            fontWeight: FontWeight.w700,
            color: theme.dashTitle,
          ),
        ),
        SizedBox(height: 16.h),
        if (briefing.revenue != null) ...[
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.trendingUp,
            title: 'Revenue & Sales',
            columns: [
              _KpiCol(
                'Yesterday',
                _gbp(briefing.revenue!.yesterday),
                _pct(briefing.revenue!.yesterdayPct),
                _variantFromPct(briefing.revenue!.yesterdayPct),
              ),
              _KpiCol(
                'MTD',
                _gbp(briefing.revenue!.mtd),
                _pct(briefing.revenue!.mtdPct),
                _variantFromPct(briefing.revenue!.mtdPct),
              ),
            ],
            summary: briefing.revenue!.summary,
          ),
          SizedBox(height: 14.h),
        ],
        if (briefing.capacity != null) ...[
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.activity,
            title: 'Capacity',
            columns: [
              _KpiCol(
                'Yesterday Completed',
                '${briefing.capacity!.completed}/${briefing.capacity!.total}',
                '${briefing.capacity!.completionRate.round()}%',
                _ChipVariant.good,
              ),
              _KpiCol(
                'Today Scheduled',
                '${briefing.capacity!.today} jobs',
                '${briefing.capacity!.today}',
                _ChipVariant.warn,
              ),
              _KpiCol(
                'Tomorrow Sched.',
                '${briefing.capacity!.tomorrow} jobs',
                '${briefing.capacity!.tomorrow}',
                _ChipVariant.warn,
              ),
            ],
            summary: briefing.capacity!.summary,
          ),
          SizedBox(height: 14.h),
        ],
        if (briefing.cash != null) ...[
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.poundSterling,
            title: 'Cash & Receivables',
            columns: [
              _KpiCol(
                'Collected Yesterday',
                _gbp(briefing.cash!.collectedYesterday),
                _gbpShort(briefing.cash!.collectedYesterday),
                _ChipVariant.good,
              ),
              _KpiCol(
                'Outstanding',
                _gbp(briefing.cash!.outstanding),
                _gbpShort(briefing.cash!.outstanding),
                _ChipVariant.warn,
              ),
              _KpiCol(
                'Overdue >30d',
                _gbp(briefing.cash!.overdue30d),
                _gbpShort(briefing.cash!.overdue30d),
                _ChipVariant.danger,
              ),
            ],
            summary: briefing.cash!.summary,
          ),
          SizedBox(height: 14.h),
        ],
        if (briefing.creditNotes != null)
          _BriefingCard(
            theme: theme,
            icon: LucideIcons.fileText,
            title: 'Credit Notes',
            columns: [
              _KpiCol(
                'MTD',
                _gbp(briefing.creditNotes!.mtd),
                _pct(briefing.creditNotes!.mtdPct),
                _ChipVariant.danger,
              ),
              _KpiCol(
                briefing.creditNotes!.topTrade ?? 'Top trade',
                _gbp(briefing.creditNotes!.topTradeAmount),
                briefing.creditNotes!.topTradePct != null
                    ? '${briefing.creditNotes!.topTradePct}%'
                    : '—',
                _ChipVariant.danger,
              ),
            ],
            summary: briefing.creditNotes!.summary,
          ),
      ],
    );
  }

  static String _gbp(double n) =>
      '£${n.round().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  static String _gbpShort(double n) {
    final v = n.abs();
    if (v >= 1000000) return '£${(n / 1000000).toStringAsFixed(2)}m';
    if (v >= 1000) return '£${(n / 1000).round()}k';
    return '£${n.round()}';
  }

  static String _pct(double? p) =>
      p == null ? '—' : (p >= 0 ? '+${p.round()}%' : '${p.round()}%');

  static _ChipVariant _variantFromPct(double? p) =>
      (p != null && p < 0) ? _ChipVariant.danger : _ChipVariant.good;
}

enum _ChipVariant { good, warn, danger }

class _KpiCol {
  const _KpiCol(this.label, this.value, this.chip, this.variant);
  final String label;
  final String value;
  final String chip;
  final _ChipVariant variant;
}

class _BriefingCard extends StatelessWidget {
  const _BriefingCard({
    required this.theme,
    required this.icon,
    required this.title,
    required this.columns,
    required this.summary,
  });

  final DashboardTheme theme;
  final IconData icon;
  final String title;
  final List<_KpiCol> columns;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return ElevatedSurface(
      padding: EdgeInsets.all(16.r),
      backgroundColor: theme.surface,
      borderColor: theme.dashCardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBlueTint,
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(icon, size: 18.sp, color: AppColors.primaryBlue),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.dashTitle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              for (var i = 0; i < columns.length; i++) ...[
                if (i > 0) SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        columns[i].label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        columns[i].value,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.text,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      _TrendChip(
                        text: columns[i].chip,
                        variant: columns[i].variant,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (summary.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Text(
              summary,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.textBody,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.text, required this.variant});

  final String text;
  final _ChipVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = switch (variant) {
      _ChipVariant.good => (AppColors.successText, AppColors.successBackground),
      _ChipVariant.warn => (AppColors.pendingText, AppColors.pendingBackground),
      _ChipVariant.danger => (AppColors.errorText, AppColors.errorBackground),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: colors.$1,
        ),
      ),
    );
  }
}

// ── AI Chat ──────────────────────────────────────────────────────────────────

class _AiChatTab extends StatelessWidget {
  const _AiChatTab({
    required this.theme,
    required this.state,
    required this.inputController,
  });

  final DashboardTheme theme;
  final ChumleyChatState state;
  final TextEditingController inputController;

  static const _prompts = [
    (LucideIcons.shieldAlert, 'Which engineers are stealing?'),
    (LucideIcons.activity, 'Which engineers are skimming?'),
    (LucideIcons.trophy, 'Show me the engineer leaderboard'),
    (LucideIcons.trendingUp, 'Show me the performance score trend for the top 3 engineers'),
    (LucideIcons.fileText, "Show me Atam Sandhu's KPIs"),
    (LucideIcons.users, 'Rank all the engineers in my trade group'),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChumleyChatCubit>();

    return Column(
      children: [
        if (state.aiError != null)
          _ErrorBanner(
            theme: theme,
            message: state.aiError!,
            onDismiss: () => cubit.clearAiError(),
          ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.border, width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: cubit.toggleAiPastChats,
                  child: Row(
                    children: [
                      Icon(LucideIcons.history, size: 13.sp, color: theme.textMuted),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          state.activeAiConversation?.title ?? 'New chat',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(LucideIcons.chevronDown, size: 13.sp, color: theme.textMuted),
                    ],
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: cubit.createAiConversation,
                icon: Icon(LucideIcons.plus, size: 14.sp),
                label: Text('New', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
        ),
        if (state.showAiPastChats)
          Container(
            constraints: BoxConstraints(maxHeight: 220.h),
            margin: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 0),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: theme.border),
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final c in state.aiConversations)
                  ListTile(
                    dense: true,
                    title: Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    selected: c.id == state.activeAiConversationId,
                    onTap: () => cubit.selectAiConversation(c.id),
                  ),
              ],
            ),
          ),
        Expanded(
          child: state.aiLoading && state.aiMessages.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.aiMessages.isEmpty
                  ? ListView(
                      padding: EdgeInsets.all(16.r),
                      children: [
                        Text(
                          'What would you like to know?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: theme.dashTitle,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Ask anything about engineer KPIs, the leaderboard, or performance trends.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.sp, color: theme.textBody),
                        ),
                        SizedBox(height: 22.h),
                        for (final (icon, prompt) in _prompts) ...[
                          _PromptCard(
                            theme: theme,
                            icon: icon,
                            prompt: prompt,
                            onTap: state.aiSending || !state.navigatorOnline
                                ? null
                                : () => cubit.sendAiMessage(prompt),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: state.aiMessages.length + (state.aiSending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (state.aiSending && index == state.aiMessages.length) {
                          return _TypingDots(theme: theme);
                        }
                        final msg = state.aiMessages[index];
                        final isUser = msg.role == 'user';
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              _Bubble(
                                theme: theme,
                                text: msg.content,
                                isUser: isUser,
                              ),
                              if (!isUser &&
                                  msg.followUps.isNotEmpty &&
                                  index == state.aiMessages.length - 1) ...[
                                SizedBox(height: 8.h),
                                Wrap(
                                  spacing: 6.w,
                                  runSpacing: 6.h,
                                  children: [
                                    for (final f in msg.followUps)
                                      ActionChip(
                                        label: Text(f, style: TextStyle(fontSize: 11.sp)),
                                        onPressed: state.aiSending
                                            ? null
                                            : () => cubit.sendAiMessage(f),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
        ),
        _Composer(
          theme: theme,
          controller: inputController,
          enabled: state.navigatorOnline && !state.aiSending,
          placeholder: state.navigatorOnline
              ? 'Type your message…'
              : 'Service unavailable…',
          onSend: () {
            final text = inputController.text;
            inputController.clear();
            cubit.sendAiMessage(text);
          },
        ),
      ],
    );
  }
}

// ── People chats ─────────────────────────────────────────────────────────────

class _ChatsTab extends StatelessWidget {
  const _ChatsTab({
    required this.theme,
    required this.state,
    required this.inputController,
    required this.dmEmailController,
  });

  final DashboardTheme theme;
  final ChumleyChatState state;
  final TextEditingController inputController;
  final TextEditingController dmEmailController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChumleyChatCubit>();

    if (state.activeChumleyConversationId != null) {
      return _ChumleyThread(
        theme: theme,
        state: state,
        inputController: inputController,
      );
    }

    return Column(
      children: [
        if (state.chumleyError != null)
          _ErrorBanner(
            theme: theme,
            message: state.chumleyError!,
            onDismiss: () => cubit.clearChumleyError(),
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'CONVERSATIONS',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (state.socketConnected)
                Icon(LucideIcons.wifi, size: 14.sp, color: AppColors.successText)
              else
                Icon(LucideIcons.wifiOff, size: 14.sp, color: theme.textMuted),
              SizedBox(width: 8.w),
              TextButton.icon(
                onPressed: () => _showNewDmDialog(context),
                icon: Icon(LucideIcons.plus, size: 14.sp),
                label: Text('New chat', style: TextStyle(fontSize: 12.sp)),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.chumleyLoading && state.chumleyConversations.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.chumleyConversations.isEmpty
                  ? Center(
                      child: Text(
                        'No conversations yet.',
                        style: TextStyle(color: theme.textMuted, fontSize: 13.sp),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: cubit.refreshChumleyConversations,
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                        itemCount: state.chumleyConversations.length,
                        separatorBuilder: (_, _) => SizedBox(height: 6.h),
                        itemBuilder: (context, index) {
                          final c = state.chumleyConversations[index];
                          final myEmail = state.chumleyMe?.email ?? '';
                          return Material(
                            color: theme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: () => cubit.openChumleyConversation(c.id),
                              child: Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: theme.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.titleFor(myEmail),
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w700,
                                              color: theme.text,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            c.lastMessagePreview.isEmpty
                                                ? 'No messages yet'
                                                : c.lastMessagePreview,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: theme.textMuted,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (c.unreadCount > 0)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 7.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          borderRadius:
                                              BorderRadius.circular(999.r),
                                        ),
                                        child: Text(
                                          '${c.unreadCount}',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Future<void> _showNewDmDialog(BuildContext context) async {
    dmEmailController.clear();
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New chat'),
        content: TextField(
          controller: dmEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Peer email',
            hintText: 'name@aspect.co.uk',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, dmEmailController.text.trim()),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    if (email != null && email.isNotEmpty && context.mounted) {
      await context.read<ChumleyChatCubit>().startDm(email);
    }
  }
}

class _ChumleyThread extends StatelessWidget {
  const _ChumleyThread({
    required this.theme,
    required this.state,
    required this.inputController,
  });

  final DashboardTheme theme;
  final ChumleyChatState state;
  final TextEditingController inputController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChumleyChatCubit>();
    final conv = state.activeChumleyConversation;
    final myEmail = state.chumleyMe?.email ?? '';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.border, width: 0.5)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(LucideIcons.arrowLeft, size: 18.sp),
                onPressed: cubit.backToChumleyList,
              ),
              Expanded(
                child: Text(
                  conv?.titleFor(myEmail) ?? 'Chat',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (state.typingEmails.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Text(
              '${state.typingEmails.join(', ')} typing…',
              style: TextStyle(fontSize: 11.sp, color: theme.textMuted),
            ),
          ),
        Expanded(
          child: state.chumleyMessagesLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: EdgeInsets.all(16.r),
                  itemCount: state.chumleyMessages.length,
                  itemBuilder: (context, index) {
                    final msg = state.chumleyMessages[index];
                    final isMe =
                        msg.authorEmail.toLowerCase() == myEmail.toLowerCase();
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Opacity(
                        opacity: msg.pending ? 0.65 : 1,
                        child: _Bubble(
                          theme: theme,
                          text: msg.text,
                          isUser: isMe,
                        ),
                      ),
                    );
                  },
                ),
        ),
        _Composer(
          theme: theme,
          controller: inputController,
          enabled: !state.chumleySending,
          placeholder: 'Type a message…',
          onSend: () {
            final text = inputController.text;
            inputController.clear();
            cubit.sendChumleyMessage(text);
          },
        ),
      ],
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  const _Composer({
    required this.theme,
    required this.controller,
    required this.enabled,
    required this.placeholder,
    required this.onSend,
  });

  final DashboardTheme theme;
  final TextEditingController controller;
  final bool enabled;
  final String placeholder;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 4.h, 7.w, 4.h),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: placeholder,
                  hintStyle: TextStyle(color: theme.textMuted, fontSize: 14.sp),
                ),
                onSubmitted: enabled ? (_) => onSend() : null,
              ),
            ),
            Material(
              color: enabled
                  ? AppColors.primaryBlue
                  : AppColors.buttonDisabledBackground,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: enabled ? onSend : null,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 36.w,
                  height: 36.w,
                  child: Icon(LucideIcons.send, color: Colors.white, size: 17.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.theme,
    required this.text,
    required this.isUser,
  });

  final DashboardTheme theme;
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.85.sw),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryBlue : theme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUser ? 16.r : 4.r),
            topRight: Radius.circular(isUser ? 4.r : 16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          border: isUser ? null : Border.all(color: theme.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: isUser ? Colors.white : theme.textBody,
            height: 1.45,
          ),
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({
    required this.theme,
    required this.icon,
    required this.prompt,
    required this.onTap,
  });

  final DashboardTheme theme;
  final IconData icon;
  final String prompt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: theme.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15.sp, color: AppColors.primaryBlue),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  prompt,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots({required this.theme});

  final DashboardTheme theme;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: theme.border),
        ),
        child: Text(
          'Thinking…',
          style: TextStyle(fontSize: 12.sp, color: theme.textMuted),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.theme,
    required this.message,
    required this.onDismiss,
  });

  final DashboardTheme theme;
  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.errorBackground,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(LucideIcons.circleAlert, size: 14.sp, color: AppColors.errorText),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 11.sp, color: AppColors.errorText),
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.x, size: 14.sp, color: AppColors.errorText),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
