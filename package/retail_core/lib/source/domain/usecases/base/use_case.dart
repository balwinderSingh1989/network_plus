part of retail_core;

abstract class UseCase<Data, Params> {
  const UseCase();

  FutureOr<Data> call(Params params);
}

class NoParams {}