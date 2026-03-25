part of '{{bloc_snake_case}}_cubit.dart';

@freezed
class {{bloc_pascal_case}}State with _${{bloc_pascal_case}}State implements BaseCubitState {
const factory {{bloc_pascal_case}}State({
@Default(PageStatus.Uninitialized) PageStatus pageStatus,
String? pageErrorMessage,
}) = _{{bloc_pascal_case}}State;

const {{bloc_pascal_case}}State._();

@override
BaseCubitState copyWithState({
PageStatus? pageStatus,
String? pageErrorMessage,
}) {
return copyWith(
pageStatus: pageStatus ?? this.pageStatus,
pageErrorMessage: pageErrorMessage,
);
}
}