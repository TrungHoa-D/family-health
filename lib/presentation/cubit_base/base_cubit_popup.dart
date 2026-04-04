import 'package:auto_route/auto_route.dart';
import 'package:family_health/di/di.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/utils/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseCubitPopup<C extends Cubit<S>, S extends BaseCubitState>
    extends StatefulWidget implements AutoRouteWrapper {
  const BaseCubitPopup({
    Key? key,
    this.screenName,
  }) : super(key: key);

  final String? screenName;

  Widget builder(BuildContext context);

  C createCubit() {
    return getIt<C>();
  }

  void onInitState(BuildContext context) {}

  void onDispose(BuildContext context) {}

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<C>(
      create: (_) => createCubit(),
      child: this,
    );
  }

  @override
  _BaseCubitPopupState createState() => _BaseCubitPopupState<C, S>();
}

class _BaseCubitPopupState<C extends Cubit<S>, S extends BaseCubitState>
    extends State<BaseCubitPopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.onInitState(context);
    });
  }

  @override
  void dispose() {
    widget.onDispose(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => hideKeyboard(),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: widget.builder(context),
      ),
    );
  }
}
