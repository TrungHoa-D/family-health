import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';

enum AppAlertType {
  success,
  error,
  warning,
  confirm,
  info,
  loading,
  loadingWithMessage
}

class AppAlertDialog {
  static int countShow = 0;

  static Future<bool?> show({
    required BuildContext context,
    String? title,
    String? message,
    AppAlertType type = AppAlertType.info,
    bool barrierDismissible = true,
    String? confirmBtnText,
    String? cancelBtnText,
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
  }) async {
    increaseDialogCount();
    FocusScope.of(context).unfocus();

    if (type == AppAlertType.loading ||
        type == AppAlertType.loadingWithMessage) {
      showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext dialogContext) {
          return PopScope(
            canPop: !barrierDismissible,
            child: type == AppAlertType.loadingWithMessage
                ? Center(
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 8,
                          children: [
                            const CircularProgressIndicator(),
                            SizedBox(
                              width: 240,
                              child: Text(
                                message ?? 'Loading...',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        },
      );
      return null;
    }

    CoolAlertType coolAlertType;
    switch (type) {
      case AppAlertType.success:
        coolAlertType = CoolAlertType.success;
        break;
      case AppAlertType.error:
        coolAlertType = CoolAlertType.error;
        break;
      case AppAlertType.warning:
        coolAlertType = CoolAlertType.warning;
        break;
      case AppAlertType.confirm:
        coolAlertType = CoolAlertType.confirm;
        break;
      default:
        coolAlertType = CoolAlertType.info;
        break;
    }

    final result = await CoolAlert.show(
      context: context,
      type: coolAlertType,
      title: title,
      text: message,
      barrierDismissible: barrierDismissible,
      confirmBtnText: confirmBtnText ?? 'Ok',
      cancelBtnText: cancelBtnText ?? 'Cancel',
      confirmBtnTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      cancelBtnTextStyle: const TextStyle(
        fontSize: 18,
        color: Colors.grey,
      ),
      onConfirmBtnTap: () {
        onConfirmBtnTap?.call();
      },
      onCancelBtnTap: () {
        onCancelBtnTap?.call();
      },
    );

    decreaseDialogCount();
    return result as bool?;
  }

  static Future<void> increaseDialogCount() async {
    countShow++;
  }

  static Future<void> decreaseDialogCount() async {
    countShow--;
  }

  static void hide(BuildContext context) {
    if (countShow > 0 && Navigator.of(context, rootNavigator: true).canPop()) {
      decreaseDialogCount();
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static Future<void> hideAll(BuildContext context) async {
    while (
        countShow > 0 && Navigator.of(context, rootNavigator: true).canPop()) {
      decreaseDialogCount();
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
