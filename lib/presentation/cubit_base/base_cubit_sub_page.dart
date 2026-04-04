import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:flutter/material.dart';

import 'base_cubit_page.dart';

abstract class BaseCubitSubPage<C extends BaseCubit<S>,
    S extends BaseCubitState> extends BaseCubitPage<C, S> {
  const BaseCubitSubPage({
    Key? key,
    super.screenName,
  }) : super(key: key);

  @override
  Widget wrappedRoute(BuildContext context) {
    return this;
  }
}
