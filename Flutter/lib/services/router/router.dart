import 'package:auto_route/auto_route.dart';
import 'package:image_classification_flutter/ui/screens/homescreen/homescreen.dart';
import 'package:image_classification_flutter/ui/screens/datasetscreen/datasetscreen.dart';

@MaterialAutoRouter(
  routes: <AutoRoute>[
    MaterialRoute(page: HomeScreen, initial: true),
    MaterialRoute(page: DatasetScreen),
  ],
)
class $PageRouter {}
