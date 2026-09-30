import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_cubit.dart';
import 'package:chumley_navigator/screens/chumley_ai/cubit/chumley_chat_state.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/ai_chat_tab_view.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/chat_header_and_tabs.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/insights_tab_view.dart';
import 'package:chumley_navigator/screens/chumley_ai/widgets/people_chats_tab_view.dart';
import 'package:chumley_navigator/utils/dashboard_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:chumley_navigator/screens/chumley_ai/widgets/ai_chat_tab_view.dart';
export 'package:chumley_navigator/screens/chumley_ai/widgets/chat_bubble.dart';
export 'package:chumley_navigator/screens/chumley_ai/widgets/chat_composer.dart';
export 'package:chumley_navigator/screens/chumley_ai/widgets/chat_error_banner.dart';
export 'package:chumley_navigator/screens/chumley_ai/widgets/chat_header_and_tabs.dart';
export 'package:chumley_navigator/screens/chumley_ai/widgets/insights_tab_view.dart';
export 'package:chumley_navigator/screens/chumley_ai/widgets/people_chats_tab_view.dart';

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
                ChatHeader(
                  theme: theme,
                  onClose: () => Navigator.maybePop(context),
                ),
                ChatTabBar(
                  theme: theme,
                  activeTab: state.activeTab,
                  showChats: true,
                  unreadTotal: state.unreadTotal,
                  onTabSelected: (tab) =>
                      context.read<ChumleyChatCubit>().selectTab(tab),
                ),
                Expanded(
                  child: switch (state.activeTab) {
                    ChumleyPanelTab.insights => InsightsTabView(
                      theme: theme,
                      state: state,
                      onRetry: () =>
                          context.read<ChumleyChatCubit>().loadBriefing(),
                    ),
                    ChumleyPanelTab.aiChat => AiChatTabView(
                      theme: theme,
                      state: state,
                      inputController: _aiInputController,
                    ),
                    ChumleyPanelTab.chats => PeopleChatsTabView(
                      theme: theme,
                      state: state,
                      inputController: _chumleyInputController,
                      dmEmailController: _dmEmailController,
                    ),
                  },
                ),
                ChatFooter(theme: theme),
              ],
            ),
          ),
        );
      },
    );
  }
}
