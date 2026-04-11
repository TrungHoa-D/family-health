import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          prev.isSaved != curr.isSaved ||
          prev.saveError != curr.saveError,
      listener: (context, state) {
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isEditing ? 'Đã cập nhật sự kiện' : 'Đã thêm sự kiện mới'),
              backgroundColor: AppColors.success,
            ),
          );
          context.router.maybePop();
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
                  state.isEditing ? 'Sửa sự kiện' : 'Thêm sự kiện y tế',
                  style: AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 8),
                    child: AppButton.mini(
                      enable: !state.isSaving,
                      title: state.isEditing ? 'Lưu thay đổi' : 'Tạo sự kiện',
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
                    // Event Title
                    _buildFieldTitle('Tiêu đề sự kiện *'),
                    TextField(
                      onChanged: cubit.updateTitle,
                      controller: TextEditingController(text: state.title)..selection = TextSelection.collapsed(offset: state.title.length),
                      style: AppStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: Khám sức khỏe tổng quát',
                        errorText: state.titleError,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Event Type
                    _buildFieldTitle('Loại sự kiện'),
                    DropdownButtonFormField<EventType>(
                      value: state.eventType,
                      items: EventType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getEventTypeName(type)),
                        );
                      }).toList(),
                      onChanged: (val) => val != null ? cubit.updateType(val) : null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Start Time
                    _buildFieldTitle('Thời gian bắt đầu'),
                    _buildDateTimePicker(
                      context: context,
                      dateTime: state.startTime,
                      onChanged: cubit.updateStartTime,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // End Time
                    _buildFieldTitle('Thời gian kết thúc'),
                    _buildDateTimePicker(
                      context: context,
                      dateTime: state.endTime,
                      onChanged: cubit.updateEndTime,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Location
                    _buildFieldTitle('Địa điểm'),
                    TextField(
                      onChanged: cubit.updateLocation,
                      controller: TextEditingController(text: state.location)..selection = TextSelection.collapsed(offset: state.location.length),
                      decoration: InputDecoration(
                        hintText: 'Nhập địa chỉ hoặc tên bệnh viện',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    _buildFieldTitle('Ghi chú (Tùy chọn)'),
                    TextField(
                      onChanged: cubit.updateDescription,
                      controller: TextEditingController(text: state.description)..selection = TextSelection.collapsed(offset: state.description.length),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Nhập thêm lời dặn của bác sĩ hoặc vật dụng cần mang theo...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusInput)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl * 2),

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
        style: AppStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
            onChanged(DateTime(date.year, date.month, date.day, time.hour, time.minute));
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
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
        return 'Tiêm chủng';
      case EventType.CHECKUP:
        return 'Khám bệnh';
      case EventType.DENTAL:
        return 'Nha khoa';
      case EventType.OTHER:
        return 'Khác';
    }
  }
}
