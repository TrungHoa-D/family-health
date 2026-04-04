import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/dependencies/dialog_manager.dart';
import 'package:flutter/material.dart';

import '../utils/alert.dart';
import 'error_entity/business_error_entity.dart';
import 'error_entity/error_entity.dart';
import 'error_entity/validation_error_entity.dart';

abstract class ErrorHandler {
  static final _errorList = <String>[];

  static void handle(
    Object error,
    DialogService dialogService, {
    VoidCallback? onPressed,
  }) {
    final message = error is ErrorEntity ? error.message : 'Error something..';

    if (_errorList.contains(message)) {
      return;
    }

    _errorList.add(message);

    final onConfirm = () {
      onPressed?.call();
      _errorList.remove(message);
    };

    if (error is SessionExpiredErrorEntity || error is UidInvalidErrorEntity) {
      dialogService.hideAll();
      _showErrorDialog(
        dialogService,
        message,
        onPressed: () async {
          onConfirm.call();
          _errorList.clear();
          // await getIt<LogoutUseCase>().call(params: null);
          // getIt<AppRouter>().replaceAll([LoginRoute()]);
        },
      );
      return;
    }
    _showErrorDialog(dialogService, message, onPressed: onConfirm);
  }

  static void _showErrorDialog(
    DialogService dialogService,
    String message, {
    VoidCallback? onPressed,
  }) {
    dialogService.show(
      title: 'error.message'.tr(),
      message: message,
      type: AppAlertType.error,
      onConfirmBtnTap: onPressed,
      barrierDismissible: false,
    );
  }
}
