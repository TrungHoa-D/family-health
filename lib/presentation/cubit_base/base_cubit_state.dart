import 'package:family_health/presentation/base/page_status.dart';

abstract class BaseCubitState {
  const BaseCubitState({
    required this.pageStatus,
    this.pageErrorMessage,
  });

  final PageStatus pageStatus;
  final String? pageErrorMessage;

  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  });
}
