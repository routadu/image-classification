import 'package:auto_route/auto_route.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

import 'datasetscreen_viewmodel.dart';

class DatasetScreen extends StatelessWidget {
  const DatasetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DatasetScreenViewModel>.reactive(
      builder: (context, model, child) {
        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(model.datasetName),
            ),
            body: Center(
              child: Text("This is dataset page"),
            ),
          ),
        );
      },
      onModelReady: (model) => model.onModelReady(),
      disposeViewModel: false,
      viewModelBuilder: () => DatasetScreenViewModel(),
    );
  }
}
