import 'package:chumley_navigator/core/responsive/responsive_overlays.dart';
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

class PeopleChatsTabView extends StatelessWidget {
  const PeopleChatsTabView({
    super.key,
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
      return ChumleyThreadView(
        theme: theme,
        state: state,
        inputController: inputController,
      );
    }

    return Column(
      children: [
        if (state.chumleyError != null)
          ChatErrorBanner(
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
                Icon(
                  LucideIcons.wifi,
                  size: 14.sp,
                  color: AppColors.successText,
                )
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
                                      borderRadius: BorderRadius.circular(
                                        999.r,
                                      ),
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
    final email = await showAppDialog<String>(
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

class ChumleyThreadView extends StatelessWidget {
  const ChumleyThreadView({
    super.key,
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
                        child: ChatBubble(
                          theme: theme,
                          text: msg.text,
                          isUser: isMe,
                        ),
                      ),
                    );
                  },
                ),
        ),
        ChatComposer(
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
