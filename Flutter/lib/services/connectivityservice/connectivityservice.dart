import 'package:connectivity/connectivity.dart';

class ConnectivityService {
  Connectivity? _connectivity;
  ConnectivityResult? _connectionStatus;
  bool boot = true;

  ConnectivityResult? get connectionStatus => _connectionStatus;

  init() {
    _connectivity = Connectivity();
    _connectivity?.onConnectivityChanged.listen(onConnectivityChanged);
  }

  onConnectivityChanged(ConnectivityResult connectivityResult) {
    _connectionStatus = connectivityResult;
  }
}
