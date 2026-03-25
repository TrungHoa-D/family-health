import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:family_health/dependencies/dialog_manager.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/common/error_converter.dart';
import 'package:family_health/shared/common/error_entity/business_error_entity.dart';
import 'package:family_health/shared/common/error_handler.dart';

abstract class BaseCubit<S extends BaseCubitState> extends Cubit<S> {
  BaseCubit(S initialState) : super(initialState);

  late DialogService _dialogService;

  void initDialogService(DialogService service) {
    _dialogService = service;
  }

  void handleError(Object error) {
    final convertedError = ErrorConverter.convert(error);

    if (convertedError is SessionExpiredErrorEntity) {
      ErrorHandler.handle(error, _dialogService);
    } else {
      emit(
        state.copyWithState(pageErrorMessage: convertedError.toString()) as S,
      );
    }
  }

  Future<void> showSuccessDialog(
    String message, {
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    return _dialogService.showSuccessDialog(
      message: message,
      onConfirmBtnTap: onPressed,
      barrierDismissible: barrierDismissible,
    );
  }

  Future<bool> showConfirmDialog(
    String message, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return _dialogService.showConfirmDialog(
      message: message,
      onConfirmBtnTap: onConfirm,
      onCancelBtnTap: onCancel,
    );
  }

  Future<void> showAlertDialog(String message, {VoidCallback? onPressed}) {
    return _dialogService.showAlertDialog(
      message: message,
      onConfirmBtnTap: onPressed,
    );
  }

  Future<void> showErrorDialog(String message, {VoidCallback? onPressed}) {
    return _dialogService.showErrorDialog(
      message: message,
      onConfirmBtnTap: onPressed,
    );
  }

  void showLoading() {
    _dialogService.showLoading(barrierDismissible: false);
  }

  void showLoadingWithMessage(String message) {
    _dialogService.showLoadingWithMessage(
      message: message,
      barrierDismissible: false,
    );
  }

  void hideLoading() {
    _dialogService.hide();
  }
}
