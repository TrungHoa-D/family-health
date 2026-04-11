import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/pages/meds/components/meds_card.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:flutter/material.dart';

class MedicationSearchDelegate extends SearchDelegate<void> {
  MedicationSearchDelegate(this.medications)
      : super(
          searchFieldLabel: 'Tìm theo tên hoặc mô tả...'.tr(),
          searchFieldStyle: AppStyles.bodyMedium,
        );

  final List<MedicationModel> medications;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) {
      return Center(
        child: Text(
          'Nhập từ khoá để tìm kiếm thuốc...',
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    final results = medications.where((m) {
      final nameMatches = m.name.toLowerCase().contains(lowerQuery);
      final descMatches =
          (m.description ?? '').toLowerCase().contains(lowerQuery);
      return nameMatches || descMatches;
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy thuốc nào khớp.',
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return MedsCard(
          medication: results[index],
          onTap: () {
            context.router
                .push(MedicationDetailRoute(medication: results[index]));
          },
        );
      },
    );
  }
}
