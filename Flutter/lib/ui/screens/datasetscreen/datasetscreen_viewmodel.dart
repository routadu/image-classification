import 'package:stacked/stacked.dart';

class DatasetScreenViewModel extends BaseViewModel {
  String _datasetName = "CIFAR 100";
  String get datasetName => _datasetName;

  Future<void> onModelReady() async {}
}
