import 'package:image_classification_flutter/services/connectivityservice/connectivityservice.dart';
import 'package:image_classification_flutter/services/datetimeservice/datetimeservice.dart';
import 'package:image_classification_flutter/services/locator/locator.dart';

class InitService {
  Future init() async {
    locator<DateTimeService>().init();
    await locator<ConnectivityService>().init();
  }
}
