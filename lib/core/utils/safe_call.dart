import '../errors/exceptions.dart';
import '../errors/failures.dart';

Future<T> safeCall<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on UnauthorizedException catch (e) {
    throw UnauthorizedFailure(e.message);
  } on ServerException catch (e) {
    throw ServerFailure(e.message);
  } on CacheException catch (e) {
    throw CacheFailure(e.message);
  } on NetworkException catch (e) {
    throw NetworkFailure(e.message);
  }
}
