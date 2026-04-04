import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/view/pages/settings/components/family_invite_section.dart';
import 'package:family_health/presentation/view/pages/settings/components/medical_records_section.dart';
import 'package:family_health/presentation/view/pages/settings/components/others_section.dart';
import 'package:family_health/presentation/view/pages/settings/components/profile_header_section.dart';
import 'package:family_health/presentation/view/pages/settings/components/routines_section.dart';
import 'package:family_health/presentation/view/pages/settings/settings_cubit.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/di/di.dart';
import 'package:auto_route/auto_route.dart';
import 'package:family_health/presentation/router/router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: const SettingsView(),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: (prev, curr) => prev.isLoggedOut != curr.isLoggedOut,
      listener: (context, state) {
        if (state.isLoggedOut) {
          context.router.replaceAll([const LoginRoute()]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surface, // Based on design, main bg is slightly off white
          body: RefreshIndicator(
            onRefresh: () => context.read<SettingsCubit>().refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  ProfileHeaderSection(
                    user: state.user,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (state.medicalRecord != null) 
                    MedicalRecordsSection(record: state.medicalRecord!),
                  const SizedBox(height: AppSpacing.lg),
                  RoutinesSection(routines: state.routines),
                  const SizedBox(height: AppSpacing.lg),
                  FamilyInviteSection(inviteCode: state.inviteCode),
                  const SizedBox(height: AppSpacing.lg),
                  const OthersSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
