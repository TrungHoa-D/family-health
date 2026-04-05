enum PageStatus { Uninitialized, Loading, Loaded, Success, Error }

extension PageStatusX on PageStatus {
  bool get isUninitialized => this == PageStatus.Uninitialized;
  bool get isLoading => this == PageStatus.Loading;
  bool get isLoaded => this == PageStatus.Loaded;
  bool get isSuccess => this == PageStatus.Success;
  bool get isError => this == PageStatus.Error;
}

enum PageState { Loading, Empty, Loaded, Error }
