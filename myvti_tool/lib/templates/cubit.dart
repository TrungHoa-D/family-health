import 'package:flutter_clean_architecture/presentation/base/page_status.dart';
import 'package:flutter_clean_architecture/presentation/cubit_base/base_cubit.dart';
import 'package:flutter_clean_architecture/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part '{{bloc_snake_case}}_cubit.freezed.dart';
part '{{bloc_snake_case}}_state.dart';

@injectable
class {{bloc_pascal_case}}Cubit extends BaseCubit<{{bloc_pascal_case}}State> {
{{bloc_pascal_case}}Cubit() : super(const {{bloc_pascal_case}}State());

Future<void> loadData() async {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
}
}