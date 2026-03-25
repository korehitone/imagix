sealed class ResultState<T> {
  const ResultState();
}

class Loading<T> extends ResultState<T> {
  const Loading();
}

class Success<T> extends ResultState<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends ResultState<T> {
  final String error;
  const Error(this.error);
}
