abstract class UseCase<T, P> {
  Future<T> call({required P params});
}

abstract class UseCaseStream<T, P> {
  Stream<T> call(P params);
}
