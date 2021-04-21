enum AsyncValueState { loading, data, error }

typedef Func<T, U> = U Function(T data);

class AsyncValue<T> {
  final AsyncValueState state;

  final T? _data;

  /// if in error state it cannot be null
  final Object? _error;
  final StackTrace? _stackTrace;

  const AsyncValue.data(T this._data)
      : state = AsyncValueState.data,
        _stackTrace = null,
        _error = null;
  const AsyncValue.loading()
      : state = AsyncValueState.loading,
        _data = null,
        _stackTrace = null,
        _error = null;
  const AsyncValue.error(Object this._error, [this._stackTrace])
      : state = AsyncValueState.error,
        _data = null;

  static Stream<AsyncValue<T>> fromFuture<T>(Future<T> future) async* {
    yield const AsyncValue.loading();

    try {
      final data = await future;
      yield AsyncValue.data(data);
      // ignore: avoid_catches_without_on_clauses
    } catch (err, st) {
      yield AsyncValue.error(err, st);
    }

    return;
  }

  U map<U>({
    required Func<T, U> data,
    required U Function() loading,
    required U Function(Object error, StackTrace? stackTrace) error,
  }) {
    switch (state) {
      case AsyncValueState.data:
        return data(_data as T);
      case AsyncValueState.loading:
        return loading();
      case AsyncValueState.error:
        return error(_error!, _stackTrace);
    }
  }

  T get requireData => map(
        data: (data) => data,
        loading: () => throw StateError('Data is not yet available'),
        error: (error, st) => throw Exception(error),
      );
}
