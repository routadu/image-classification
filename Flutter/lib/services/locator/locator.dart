import 'package:get_it/get_it.dart';
import 'package:image_classification_flutter/services/router/router.gr.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_classification_flutter/services/connectivityservice/connectivityservice.dart';
import 'package:image_classification_flutter/services/datetimeservice/datetimeservice.dart';
import 'package:image_classification_flutter/services/initservice/initservice.dart';
import 'package:image_classification_flutter/ui/screens/homescreen/homescreen_viewmodel.dart';

GetIt locator = GetIt.asNewInstance();

void setupLocator() {
  // ? Services
  locator.registerLazySingleton(() => PageRouter());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => InitService());
  locator.registerLazySingleton(() => DateTimeService());
  locator.registerLazySingleton(() => ConnectivityService());

  // ? ViewModels
  locator.registerLazySingleton(() => HomeScreenViewModel());
}
