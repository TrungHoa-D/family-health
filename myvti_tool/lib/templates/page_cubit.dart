import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_architecture/presentation/cubit_base/base_cubit_page.dart';

import '{{bloc_snake_case}}_cubit.dart';

@RoutePage()
class {{bloc_pascal_case}}Page extends BaseCubitPage<{{bloc_pascal_case}}Cubit, {{bloc_pascal_case}}State> {
const {{bloc_pascal_case}}Page({super.key});

@override
void onInitState(BuildContext context) {
super.onInitState(context);
context.read<{{bloc_pascal_case}}Cubit>().loadData();
}

@override
Widget builder(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('{{bloc_pascal_case}}'),
),
body: const Center(
child: Text('{{bloc_pascal_case}} Page Content'),
),
);
}
}