import 'package:auto_route/auto_route.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/view/pages/home/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/simplified_home_view.dart';
import 'components/standard_home_view.dart';

@RoutePage()
class HomePage extends BaseCubitPage<HomeCubit, HomeState> {
  const HomePage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<HomeCubit>().loadData();
  }

  @override
  void onErrorPressed(BuildContext context) {
    context.read<HomeCubit>().loadData();
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final uiPreference = state.user?.uiPreference ?? 'standard';

        if (uiPreference == 'simplified' && state.currentTabIndex == 0) {
          return SimplifiedHomeView(
            userName: state.user?.displayName,
            progress: state.todayStats?.completionPercentage ?? 0.0,
            meds: state.simplifiedMeds,
            onTakenMedication: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('common.confirm'.tr()),
                  content: Text('simplified.taken_confirm'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('simplified.not_yet'.tr()),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeCubit>().markNearestDoseAsTaken();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('simplified.recorded'.tr())),
                        );
                      },
                      child: Text('simplified.yes_done'.tr()),
                    ),
                  ],
                ),
              );
            },
            onEmergencyCall: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('simplified.calling'.tr()),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            onChatTap: () {
              context.router.push(const ChatRoute());
            },
            onAiChatTap: () {
              context.router.push(const AIChatSupportRoute());
            },
            onExitSimplifiedMode: () =>
                context.read<HomeCubit>().exitSimplifiedMode(),
          );
        }

        return StandardHomeView(
          currentIndex: state.currentTabIndex,
          onTabChanged: (index) => context.read<HomeCubit>().changeTab(index),
        );
      },
    );
  }
}
