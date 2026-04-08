import 'package:auto_route/auto_route.dart';
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
            onTakenMedication: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('common.confirm'.tr()),
                  content: Text('Bạn đã uống thuốc rồi đúng không?'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Chưa'.tr()),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Gọi UseCase ghi nhận log
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã ghi nhận!'.tr())),
                        );
                      },
                      child: Text('Đúng vậy'.tr()),
                    ),
                  ],
                ),
              );
            },
            onEmergencyCall: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang gọi cho người thân...'),
                  backgroundColor: Colors.redAccent,
                ),
              );
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
