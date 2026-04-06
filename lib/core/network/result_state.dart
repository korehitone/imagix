sealed class ResultState<T> {
  const ResultState();
}

// class Loading<T> extends ResultState<T> {
//   const Loading();
// }

class Success<T> extends ResultState<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends ResultState<T> {
  final String error;
  const Error(this.error);
}

extension ResultStateX<T> on ResultState<T> {
  // Fungsi pembantu buat 'ngupas' otomatis buat Riverpod
  T getOrThrow() {
    return switch (this) {
      Success(data: final d) => d,
      Error(error: final msg) => throw msg, // Lempar biar ditangkep .guard
    };
  }
}
