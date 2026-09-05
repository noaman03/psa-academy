/// Standardized UI state wrapper for PSA Academy V2 controllers.
enum ViewStatus {
  initial,
  loading,
  success,
  empty,
  failure,
}

class ViewState<T> {
  final ViewStatus status;
  final T? data;
  final String? errorMessage;

  const ViewState._({
    required this.status,
    this.data,
    this.errorMessage,
  });

  const ViewState.initial() : this._(status: ViewStatus.initial);

  const ViewState.loading([T? existingData])
      : this._(status: ViewStatus.loading, data: existingData);

  const ViewState.success(T data)
      : this._(status: ViewStatus.success, data: data);

  const ViewState.empty() : this._(status: ViewStatus.empty);

  const ViewState.failure(String message, [T? existingData])
      : this._(
          status: ViewStatus.failure,
          errorMessage: message,
          data: existingData,
        );

  bool get isInitial => status == ViewStatus.initial;
  bool get isLoading => status == ViewStatus.loading;
  bool get isSuccess => status == ViewStatus.success;
  bool get isEmpty => status == ViewStatus.empty;
  bool get isFailure => status == ViewStatus.failure;
}
