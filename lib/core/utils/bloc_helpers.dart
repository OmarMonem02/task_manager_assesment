import '../errors/failures.dart';

typedef BlocErrorHandler<E> = void Function(E emit, String message);

Future<void> runBlocAction<E>({
  required Future<void> Function() action,
  required E Function(String message) onError,
  required void Function(E state) emit,
  String fallbackMessage = 'Something went wrong',
}) async {
  try {
    await action();
  } on UnauthorizedFailure catch (e) {
    emit(onError(e.message));
  } on ServerFailure catch (e) {
    emit(onError(e.message));
  } catch (_) {
    emit(onError(fallbackMessage));
  }
}

String failureMessage(Object error, {String fallback = 'Something went wrong'}) {
  if (error is UnauthorizedFailure) return error.message;
  if (error is ServerFailure) return error.message;
  if (error is CacheFailure) return error.message;
  if (error is NetworkFailure) return error.message;
  return fallback;
}
