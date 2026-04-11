import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_form_field.dart';
import 'package:flutter/material.dart';

/// Section form thông số kho: Ngày hết hạn, Số lượng, Đơn vị
class InventoryInfoSection extends StatelessWidget {
  const InventoryInfoSection({
    super.key,
    this.expiryDate,
    required this.stockQuantity,
    required this.unit,
    this.expiryDateError,
    required this.onExpiryDateChanged,
    required this.onStockQuantityChanged,
    required this.onUnitChanged,
    this.isAiFilled = false,
  });

  final DateTime? expiryDate;
  final String stockQuantity;
  final String unit;
  final String? expiryDateError;
  final ValueChanged<DateTime?> onExpiryDateChanged;
  final ValueChanged<String> onStockQuantityChanged;
  final ValueChanged<String> onUnitChanged;
  final bool isAiFilled;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onExpiryDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'meds.inventory_info_section'.tr(),
              style: AppStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isAiFilled) _buildAiBadge(),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expiry Date field
              Row(
                children: [
                  Text(
                    'meds.expiry_date_label'.tr(),
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
                  ),
                  const Text(' *', style: TextStyle(color: AppColors.error)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isAiFilled
                        ? AppColors.aiFilledBackground
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
                    border: expiryDateError != null
                        ? Border.all(color: AppColors.error, width: 1)
                        : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        expiryDate != null
                            ? DateFormat('dd/MM/yyyy').format(expiryDate!)
                            : 'meds.expiry_date_hint'.tr(),
                        style: AppStyles.bodyMedium.copyWith(
                          color: expiryDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          size: 20,
                          color: AppColors.primary.withValues(alpha: 0.4)),
                    ],
                  ),
                ),
              ),
              if (expiryDateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: Text(
                    expiryDateError!.tr(),
                    style:
                        AppStyles.labelSmall.copyWith(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  // Stock quantity
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'meds.stock_quantity_label'.tr(),
                          style: AppStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildInputField(
                          value: stockQuantity,
                          hintText: '0',
                          onChanged: onStockQuantityChanged,
                          isAiFilled: isAiFilled,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Unit
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'meds.unit_label'.tr(),
                          style: AppStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildInputField(
                          value: unit,
                          hintText: 'meds.unit_hint'.tr(),
                          onChanged: onUnitChanged,
                          isAiFilled: isAiFilled,
                          suffixIcon: PopupMenuButton<String>(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.primary.withValues(alpha: 0.8),
                            ),
                            onSelected: onUnitChanged,
                            itemBuilder: (BuildContext context) {
                              return const [
                                PopupMenuItem(value: 'Viên', child: Text('Viên')),
                                PopupMenuItem(value: 'Vỉ', child: Text('Vỉ')),
                                PopupMenuItem(value: 'Hộp', child: Text('Hộp')),
                                PopupMenuItem(value: 'Lọ', child: Text('Lọ')),
                                PopupMenuItem(value: 'Chai', child: Text('Chai')),
                                PopupMenuItem(value: 'Gói', child: Text('Gói')),
                                PopupMenuItem(value: 'Ống', child: Text('Ống')),
                                PopupMenuItem(value: 'Tuýp', child: Text('Tuýp')),
                              ];
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String value,
    required String hintText,
    required ValueChanged<String> onChanged,
    bool isAiFilled = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isAiFilled ? AppColors.aiFilledBackground : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
      ),
      child: AppFormField(
        value: value,
        hintText: hintText,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          fillColor:
              isAiFilled ? AppColors.aiFilledBackground : AppColors.white,
          suffixIcon: suffixIcon ??
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Icon(
                  Icons.edit,
                  color: AppColors.primary.withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.aiFilledBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFA33200)),
          const SizedBox(width: 4),
          Text(
            'meds.ai_filled'.tr(),
            style: AppStyles.labelSmall.copyWith(
              color: const Color(0xFFA33200),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
