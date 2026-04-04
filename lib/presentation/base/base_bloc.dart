import 'package:bloc/bloc.dart';
import 'package:family_health/dependencies/dialog_manager.dart';
import 'package:family_health/presentation/base/base_state.dart';
import 'package:family_health/shared/common/error_converter.dart';
import 'package:family_health/shared/common/error_entity/business_error_entity.dart';
import 'package:family_health/shared/common/error_entity/validation_error_entity.dart';
import 'package:family_health/shared/common/error_handler.dart';
import 'package:family_health/shared/utils/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BaseBloc<V, S extends BaseState> extends Bloc<V, S> {
  BaseBloc(S initialState) : super(initialState);

  late DialogService _dialogService;

  void initDialogService(DialogService service) {
    _dialogService = service;
  }

  void handlePageLoadFailed<S>(Emitter<S> emit, Object error) {
    final errorConvert = ErrorConverter.convert(error);
    if (errorConvert is SessionExpiredErrorEntity ||
        errorConvert is UidInvalidErrorEntity) {
      ErrorHandler.handle(errorConvert, _dialogService);
    }
  }

  void handleError<S>(Emitter<S> emit, Object error) {
    ErrorHandler.handle(error, _dialogService);
  }

  Future showSuccessDialog(
    String message, {
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) async {
    await _dialogService.show(
      message: message,
      type: AppAlertType.success,
      onConfirmBtnTap: onPressed,
      barrierDismissible: barrierDismissible,
    );
  }

  Future showConfirmDialog(
    String message, {
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    await _dialogService.show(
      message: message,
      type: AppAlertType.confirm,
      onConfirmBtnTap: onConfirm,
      onCancelBtnTap: onCancel,
    );
  }

  Future showAlertDialog(String message, {VoidCallback? onPressed}) async {
    await _dialogService.show(
      message: message,
      type: AppAlertType.info,
      onConfirmBtnTap: onPressed,
    );
  }

  Future showErrorDialog(String message, {VoidCallback? onPressed}) {
    return _dialogService.show(
      message: message,
      type: AppAlertType.error,
      onConfirmBtnTap: onPressed,
    );
  }

  void showLoading() {
    _dialogService.show(
      type: AppAlertType.loading,
      barrierDismissible: false,
    );
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
