import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/shared/extension/theme_data.dart';

import 'home_cubit.dart';

@RoutePage()
class HomePage extends BaseCubitPage<HomeCubit, HomeState> {
  const HomePage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<HomeCubit>().loadData();
  }

  @override
  Widget builder(BuildContext context) {
    final themeOwn = Theme.of(context).own();
    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<HomeCubit>().signOut();
              if (context.mounted) {
                context.router.replaceAll([const LoginRoute()]);
              }
            },
            icon: const Icon(Icons.logout),
            tooltip: 'home.logout'.tr(),
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final user = state.user;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    backgroundColor: AppColors.surface,
                    child: user?.photoUrl == null
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: themeOwn.colorSchema?.subText,
                          )
                        : null,
                  ),
                  Text(
                    '${'home.welcome'.tr()}, ${user?.displayName ?? 'home.user'.tr()}!',
                    style: themeOwn.textTheme?.h2,
                    textAlign: TextAlign.center,
                  ),
                  if (user?.email != null)
                    Text(
                      user!.email!,
                      style: themeOwn.textTheme?.primary?.copyWith(
                        color: themeOwn.colorSchema?.subText,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}