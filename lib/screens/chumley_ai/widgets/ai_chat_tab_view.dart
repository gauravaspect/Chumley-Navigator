import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_cubit.dart';
import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_state.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/chat_bubble.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/chat_composer.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/chat_error_banner.dart';
import 'package:chumley_navigator/utils/colors.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AiChatTabView extends StatelessWidget {
  const AiChatTabView({
    super.key,
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
    (
      LucideIcons.trendingUp,
      'Show me the performance score trend for the top 3 engineers',
    ),
    (LucideIcons.fileText, "Show me Atam Sandhu's KPIs"),
    (LucideIcons.users, 'Rank all the engineers in my trade group'),
  ];

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChumleyChatCubit>();

    return Column(
      children: [
        if (state.aiError != null)
          ChatErrorBanner(
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
                      Icon(
                        LucideIcons.history,
                        size: 13.sp,
                        color: theme.textMuted,
                      ),
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
                      Icon(
                        LucideIcons.chevronDown,
                        size: 13.sp,
                        color: theme.textMuted,
                      ),
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
                    title: Text(
                      c.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                  itemCount:
                      state.aiMessages.length + (state.aiSending ? 1 : 0),
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
                          ChatBubble(
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
                                    label: Text(
                                      f,
                                      style: TextStyle(fontSize: 11.sp),
                                    ),
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
        ChatComposer(
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
