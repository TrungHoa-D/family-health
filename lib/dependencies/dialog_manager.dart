import 'package:family_health/shared/utils/alert.dart';
import 'package:flutter/material.dart';

abstract class DialogService {
  Future<dynamic> show({
    String? message,
    String? title,
    required AppAlertType type,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
    bool barrierDismissible = true,
  });

  Future<void> showSuccessDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
    bool barrierDismissible = true,
  });

  Future<bool> showConfirmDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
  });

  Future<void> showAlertDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
  });

  Future<void> showErrorDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
  });

  void showLoading({bool barrierDismissible = false});

  void showLoadingWithMessage({
    required String message,
    bool barrierDismissible = false,
  });

  void hide();

  void hideAll();
}

class AppDialogService implements DialogService {
  AppDialogService(this.context);

  final BuildContext context;

  @override
  Future<dynamic> show({
    String? title,
    String? message,
    required AppAlertType type,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
    bool barrierDismissible = true,
  }) async {
    return AppAlertDialog.show(
      title: title,
      context: context,
      message: message,
      type: type,
      onConfirmBtnTap: onConfirmBtnTap,
      onCancelBtnTap: onCancelBtnTap,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Future<void> showSuccessDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
    bool barrierDismissible = true,
  }) {
    return show(
      message: message,
      type: AppAlertType.success,
      onConfirmBtnTap: onConfirmBtnTap,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Future<bool> showConfirmDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
  }) async {
    final result = await show(
      message: message,
      type: AppAlertType.confirm,
      onConfirmBtnTap: onConfirmBtnTap,
      onCancelBtnTap: onCancelBtnTap,
    );
    return result == true;
  }

  @override
  Future<void> showAlertDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
  }) {
    return show(
      message: message,
      type: AppAlertType.info,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  @override
  Future<void> showErrorDialog({
    required String message,
    VoidCallback? onConfirmBtnTap,
  }) {
    return show(
      message: message,
      type: AppAlertType.error,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  @override
  void showLoading({bool barrierDismissible = false}) {
    show(
      type: AppAlertType.loading,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  void showLoadingWithMessage({
    required String message,
    bool barrierDismissible = false,
  }) {
    show(
      message: message,
      type: AppAlertType.loadingWithMessage,
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  void hide() {
    AppAlertDialog.hide(context);
  }

  @override
  void hideAll() {
    AppAlertDialog.hideAll(context);
  }
}
