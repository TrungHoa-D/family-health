import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'add_event_cubit.dart';

@RoutePage()
class AddEventPage extends BaseCubitPage<AddEventCubit, AddEventState> {
  const AddEventPage({super.key, this.event});
  final MedicalEvent? event;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<AddEventCubit>().init(event: event);
  }

  @override
  Widget builder(BuildContext context) {
    return BlocConsumer<AddEventCubit, AddEventState>(
      listenWhen: (prev, curr) =>
          prev.isSaved != curr.isSaved || prev.saveError != curr.saveError,
      listener: (context, state) {
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isEditing
                  ? 'events.edit_event'.tr()
                  : 'events.add_event'.tr()),
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
        final cubit = context.read<AddEventCubit>();

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                  onPressed: () => context.router.maybePop(),
                ),
                title: Text(
                  state.isEditing
                      ? 'events.edit_event'.tr()
                      : 'events.add_event'.tr(),
                  style: AppStyles.titleLarge
                      .copyWith(color: AppColors.textPrimary),
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 8),
                    child: AppButton.mini(
                      enable: !state.isSaving,
                      title: state.isEditing
                          ? 'common.save'.tr()
                          : 'common.save'.tr(),
                      onPressed: () => cubit.save(),
                    ),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Illustration
                    _buildFieldTitle('events.image_section.title'.tr()),
                    _buildIllustration(state),
                    const SizedBox(height: AppSpacing.lg),

                    // Event Title
                    _buildFieldTitle('events.fields.title'.tr()),
                    TextField(
                      onChanged: cubit.updateTitle,
                      controller: TextEditingController(text: state.title)
                        ..selection =
                            TextSelection.collapsed(offset: state.title.length),
                      style: AppStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Khám sức khỏe tổng quát',
                        errorText: state.titleError,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Event Type
                    _buildFieldTitle('events.fields.type'.tr()),
                    DropdownButtonFormField<EventType>(
                      value: state.eventType,
                      items: EventType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getEventTypeName(type)),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          val != null ? cubit.updateType(val) : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Medication Picker (Conditional)
                    if (state.eventType == EventType.MEDICATION ||
                        state.eventType == EventType.VACCINE) ...[
                      _buildFieldTitle('events.medication_picker.title'.tr()),
                      _buildMedicationPicker(context, state),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Start Time
                    _buildFieldTitle('events.fields.start_time'.tr()),
                    _buildDateTimePicker(
                      context: context,
                      dateTime: state.startTime,
                      onChanged: cubit.updateStartTime,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // End Time
                    _buildFieldTitle('events.fields.end_time'.tr()),
                    _buildDateTimePicker(
                      context: context,
                      dateTime: state.endTime,
                      onChanged: cubit.updateEndTime,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Location
                    _buildFieldTitle('events.fields.location'.tr()),
                    TextField(
                      onChanged: cubit.updateLocation,
                      controller: TextEditingController(text: state.location)
                        ..selection = TextSelection.collapsed(
                            offset: state.location.length),
                      decoration: InputDecoration(
                        hintText: 'Nhập địa chỉ hoặc tên bệnh viện',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    _buildFieldTitle('events.fields.note'.tr()),
                    TextField(
                      onChanged: cubit.updateDescription,
                      controller: TextEditingController(text: state.description)
                        ..selection = TextSelection.collapsed(
                            offset: state.description.length),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Nhập thêm lời dặn của bác sĩ hoặc vật dụng cần mang theo...',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Participants
                    if (state.familyMembers.isNotEmpty) ...[
                      _buildFieldTitle('events.fields.participants'.tr()),
                      Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.sm,
                        children: state.familyMembers.map((member) {
                          final isSelected =
                              state.selectedParticipantIds.contains(member.uid);
                          return GestureDetector(
                            onTap: () => cubit.toggleParticipant(member.uid),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isSelected ? 1.0 : 0.4,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: isSelected
                                        ? BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: AppColors.primary,
                                                width: 2),
                                          )
                                        : null,
                                    child: AppAvatar.medium(
                                        imageUrl: member.avatarUrl),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    member.displayName?.split(' ').last ?? '',
                                    style: AppStyles.labelSmall.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl * 2),
                    ],
                  ],
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

  Widget _buildFieldTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        title,
        style: AppStyles.labelLarge.copyWith(
            fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required DateTime dateTime,
    required Function(DateTime) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: dateTime,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (date != null && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(dateTime),
          );
          if (time != null) {
            onChanged(DateTime(
                date.year, date.month, date.day, time.hour, time.minute));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(dateTime),
              style: AppStyles.bodyLarge,
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _getEventTypeName(EventType type) {
    switch (type) {
      case EventType.VACCINE:
        return 'events.type.vaccine'.tr();
      case EventType.CHECKUP:
        return 'events.type.checkup'.tr();
      case EventType.DENTAL:
        return 'events.type.dental'.tr();
      case EventType.MEDICATION:
        return 'events.type.medication'.tr();
      case EventType.OTHER:
        return 'events.type.other'.tr();
    }
  }

  Widget _buildIllustration(AddEventState state) {
    String assetPath;
    switch (state.eventType) {
      case EventType.VACCINE:
        assetPath = 'assets/images/event_vaccine.png';
        break;
      case EventType.CHECKUP:
        assetPath = 'assets/images/event_checkup.png';
        break;
      case EventType.DENTAL:
        assetPath = 'assets/images/event_dental.png';
        break;
      case EventType.MEDICATION:
        assetPath = 'assets/images/event_medication.png';
        break;
      case EventType.OTHER:
        assetPath = 'assets/images/event_other.png';
        break;
    }

    return AppCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: (state.imageUrl != null && state.imageUrl!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: state.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) =>
                        Image.asset(assetPath, fit: BoxFit.cover),
                  )
                : Image.asset(assetPath, fit: BoxFit.cover),
          ),
          if (state.selectedMedication != null)
            Positioned(
              bottom: AppSpacing.sm,
              right: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  state.selectedMedication!.name,
                  style: AppStyles.labelSmall.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicationPicker(BuildContext context, AddEventState state) {
    final cubit = context.read<AddEventCubit>();
    final selectedMedicationId = state.availableMedications.any(
      (m) => m.id == state.medicationId,
    )
        ? state.medicationId
        : null;

    return Column(
      children: [
        DropdownButtonFormField<String?>(
          value: selectedMedicationId,
          hint: Text('events.medication_picker.hint'.tr()),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('events.medication_picker.none'.tr()),
            ),
            ...state.availableMedications.map((m) => DropdownMenuItem<String?>(
                  value: m.id,
                  child: Row(
                    children: [
                      if (m.imageUrl != null)
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(m.imageUrl!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Text(m.name),
                    ],
                  ),
                )),
          ],
          onChanged: (id) {
            final med =
                state.availableMedications.where((m) => m.id == id).firstOrNull;
            cubit.selectMedication(med);
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusInput)),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              context.router.push(AddMedicationRoute());
            },
            icon: const Icon(Icons.add, size: 16),
            label: Text('events.medication_picker.add_new'.tr()),
          ),
        ),
      ],
    );
  }
}
