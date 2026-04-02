import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/router/router.dart';

import 'components/meds_filter_bar.dart';
import 'components/meds_header.dart';
import 'components/meds_list_section.dart';
import 'components/meds_refill_section.dart';
import 'meds_cubit.dart';

@RoutePage()
class MedsPage extends BaseCubitPage<MedsCubit, MedsState> {
  const MedsPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<MedsCubit>().loadData();
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<MedsCubit, MedsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const MedsHeader(),
                  MedsFilterBar(
                    selectedIndex: state.selectedFilterIndex,
                    onSelected: (index) =>
                        context.read<MedsCubit>().changeFilter(index),
                  ),
                  MedsListSection(
                    medications: state.medications,
                    onMedicationTap: (medication) {
                      context.router.push(
                        MedicationDetailRoute(medication: medication),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  MedsRefillSection(refills: state.refills),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.router.push(AddMedicationRoute());
            },
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        );
      },
    );
  }
}
