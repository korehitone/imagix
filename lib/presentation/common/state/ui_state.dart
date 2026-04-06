// T adalah 'Kantong Data' lu (bisa List, Objek, atau Class isi 3 List)
sealed class UIState<T> {
  final T data;
  const UIState(this.data);
}

class Initial<T> extends UIState<T> {
  const Initial(super.data);
}

class Loading<T> extends UIState<T> {
  const Loading(super.data);
}

class Success<T> extends UIState<T> {
  const Success(super.data);
}

class Error<T> extends UIState<T> {
  final String message;
  const Error(this.message, T data) : super(data);
}
