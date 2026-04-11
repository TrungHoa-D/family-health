import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        // Build dynamic filter labels
        final filterLabels = <String>[
          'meds.filter_all'.tr(),
          ...state.topCategoryNames,
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  MedsHeader(
                    medications: state.medications,
                    onAddMedication: () {
                      context.router.push(AddMedicationRoute()).then((_) {
                        if (context.mounted) {
                          context.read<MedsCubit>().loadData();
                        }
                      });
                    },
                  ),
                  MedsFilterBar(
                    selectedIndex: state.selectedFilterIndex,
                    filterLabels: filterLabels,
                    onSelected: (index) =>
                        context.read<MedsCubit>().changeFilter(index),
                    onViewMore: () {
                      context.router.push(CategoryListRoute());
                    },
                  ),
                  MedsListSection(
                    medications: state.filteredMedications,
                    onMedicationTap: (medication) {
                      context.router.push(
                        MedicationDetailRoute(medication: medication),
                      ).then((_) {
                        if (context.mounted) {
                          context.read<MedsCubit>().loadData();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  MedsRefillSection(refills: state.refills),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
