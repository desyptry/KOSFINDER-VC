enum KosLoadStatus {
  loading,
  success,
  empty,
  notFound,
  error,
}

class KosLoadResult<T> {
  const KosLoadResult._({
    required this.status,
    this.data,
    this.message,
  });

  const KosLoadResult.loading()
      : this._(status: KosLoadStatus.loading);

  const KosLoadResult.success(T data)
      : this._(status: KosLoadStatus.success, data: data);

  const KosLoadResult.empty()
      : this._(status: KosLoadStatus.empty);

  const KosLoadResult.notFound()
      : this._(status: KosLoadStatus.notFound);

  const KosLoadResult.error(String message)
      : this._(status: KosLoadStatus.error, message: message);

  final KosLoadStatus status;
  final T? data;
  final String? message;
}
