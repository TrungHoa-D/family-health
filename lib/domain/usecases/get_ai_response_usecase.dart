import 'dart:io';
import 'package:family_health/domain/repositories/ai_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class GetAIResponseParams {
  GetAIResponseParams({required this.prompt, this.image});
  final String prompt;
  final File? image;
}

@injectable
class GetAIResponseUseCase extends UseCase<String, GetAIResponseParams> {
  GetAIResponseUseCase(this._repository);
  final AIRepository _repository;

  @override
  Future<String> call({required GetAIResponseParams params}) {
    return _repository.getAIResponse(params.prompt, image: params.image);
  }
}
