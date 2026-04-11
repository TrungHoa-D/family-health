import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/view/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_edit_cubit.dart';

@RoutePage()
class ProfileEditPage
    extends BaseCubitPage<ProfileEditCubit, ProfileEditState> {
  const ProfileEditPage({super.key, required this.user});
  final UserEntity user;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<ProfileEditCubit>().init(user);
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      context.read<ProfileEditCubit>().updateAvatarFile(File(pickedFile.path));
    }
  }

  @override
  Widget builder(BuildContext context) {
    return BlocConsumer<ProfileEditCubit, ProfileEditState>(
      listenWhen: (prev, curr) =>
          prev.isSuccess != curr.isSuccess ||
          prev.saveError != curr.saveError,
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.save_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
          context.router.maybePop(true);
          return;
        }

        if (state.saveError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.saveError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ProfileEditCubit>();

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.surface,
              appBar: AppBar(
                backgroundColor: AppColors.surface,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () => context.router.maybePop(),
                ),
                title: Text(
                  'settings.edit_profile_title'.tr(),
                  style:
                      AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 8),
                    child: AppButton.mini(
                      enable: !state.isSaving,
                      title: 'settings.save_changes'.tr(),
                      onPressed: () => cubit.updateProfile(currentUser: user),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: GestureDetector(
                          onTap: () => _pickImage(context),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.secondary,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Container(
                                    color: AppColors.surface,
                                    child: state.avatarFile != null
                                        ? Image.file(
                                            state.avatarFile!,
                                            fit: BoxFit.cover,
                                          )
                                        : (user.avatarUrl?.isNotEmpty == true
                                            ? CachedNetworkImage(
                                                imageUrl: user.avatarUrl!,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    const Icon(Icons.error),
                                              )
                                            : Center(
                                                child: Text(
                                                  user.displayName?.isNotEmpty ==
                                                          true
                                                      ? user.displayName![0]
                                                      : 'U',
                                                  style: AppStyles.displayLarge
                                                      .copyWith(
                                                          color: AppColors.primary),
                                                ),
                                              )),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: AppColors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppFormField(
                        value: state.name,
                        hintText: 'common.full_name'.tr(),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: cubit.updateName,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppFormField(
                        value: state.phoneNumber,
                        hintText: 'common.phone_number'.tr(),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: cubit.updatePhone,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Email: ${user.email}',
                        style: AppStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ),
            if (state.isSaving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}
