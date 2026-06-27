import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class ConnectivityService {
  Future<bool> get isOnline;
  Stream<bool> get onConnectivityChanged;
}

class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({InternetConnection? checker})
      : _checker = checker ?? InternetConnection();

  final InternetConnection _checker;

  @override
  Future<bool> get isOnline => _checker.hasInternetAccess;

  @override
  Stream<bool> get onConnectivityChanged => _checker.onStatusChange.map(
        (status) => status == InternetStatus.connected,
      );
}
