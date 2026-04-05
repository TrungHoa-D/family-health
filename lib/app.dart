import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:one_context/one_context.dart';

import 'package:family_health/presentation/resources/themes.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/pages/auth/global_auth_cubit.dart';

import 'di/di.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppRouter appRouter;

  @override
  void initState() {
    appRouter = getIt<AppRouter>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GlobalAuthCubit>()..init(),
      child: BlocListener<GlobalAuthCubit, GlobalAuthState>(
        listenWhen: (prev, curr) => prev.sessionStatus != curr.sessionStatus,
        listener: (context, state) {
          if (state.sessionStatus == SessionStatus.expired) {
            CoolAlert.show(
              context: OneContext().context!,
              type: CoolAlertType.warning,
              title: 'Phiên làm việc hết hạn',
              text: 'Vui lòng đăng nhập lại để tiếp tục.',
              confirmBtnText: 'OK',
              onConfirmBtnTap: () {
                context.read<GlobalAuthCubit>().acknowledgeLogout();
              },
            );
          } else if (state.sessionStatus == SessionStatus.loggedOut) {
            appRouter.replaceAll([const LoginRoute()]);
          }
        },
        child: MaterialApp.router(
          routerDelegate: appRouter.delegate(),
          routeInformationParser: appRouter.defaultRouteParser(),
          routeInformationProvider: appRouter.routeInfoProvider(),
          debugShowCheckedModeBanner: false,
          builder: OneContext().builder,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
        ),
      ),
    );
  }
}
