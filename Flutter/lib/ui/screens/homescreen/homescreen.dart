import 'homescreen_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeScreenViewModel>.reactive(
      builder: (context, model, child) {
        return SafeArea(
          child: Scaffold(
            appBar: _AppBar(model),
            body: _Body(model),
          ),
        );
      },
      onModelReady: (model) => model.onModelReady(),
      disposeViewModel: false,
      viewModelBuilder: () => HomeScreenViewModel(),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeScreenViewModel model;
  const _AppBar(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue[400],
      title: const Text("Image Classification"),
      actions: [
        _ModelButton(model),
        const SizedBox(width: 12),
        _TrainButton(model),
        const SizedBox(width: 7),
        _TrainingStateLED(model.trainingState),
        const SizedBox(width: 12),
        _TextToSpeechButton(model),
        const SizedBox(width: 12),
        _PlotGraphButton(model),
        const SizedBox(width: 15),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Body extends StatelessWidget {
  final HomeScreenViewModel model;
  const _Body(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TrainingState _ts = model.trainingState;
    final bool _showTrainedModelView =
        _ts == TrainingState.success || _ts == TrainingState.result;
    return Container(
        alignment: Alignment.center,
        child: _showTrainedModelView
            ? _TrainedModelView(model)
            : _UntrainedModelView(model));
  }
}

class _UntrainedModelView extends StatelessWidget {
  final HomeScreenViewModel model;
  const _UntrainedModelView(this.model, {Key? key}) : super(key: key);

  List<dynamic> decideWidgets() {
    final List<dynamic> _list = [];
    final TrainingState _ts = model.trainingState;
    String text;
    IconData icon;
    switch (_ts) {
      case TrainingState.unconnected:
        text = "Not connected to the server";
        icon = Icons.wifi_off_outlined;
        break;
      case TrainingState.connecting:
        text = "Connecting to the server";
        icon = Icons.wifi;
        break;
      case TrainingState.untrained:
        text = "Model not trained";
        icon = Icons.pivot_table_chart_outlined;
        break;
      case TrainingState.training:
        text = "Training the model";
        icon = Icons.model_training_outlined;
        break;
      default:
        text = "Please Wait...";
        icon = Icons.error_outline_outlined;
    }
    _list.add(
      Text(
        text,
        style: const TextStyle(fontSize: 20),
      ),
    );
    _list.add(Icon(
      icon,
      size: 120,
      color: Colors.grey[600],
    ));
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> _widgets = decideWidgets();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _widgets[1],
        const SizedBox(height: 50),
        _widgets[0],
      ],
    );
  }
}

class _TrainedModelView extends StatelessWidget {
  final HomeScreenViewModel model;
  const _TrainedModelView(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        !model.isImagePicked
            ? GestureDetector(
                onTap: model.pickImageFromUser,
                child: DottedBorder(
                  color: Colors.grey[400] ?? Colors.grey,
                  strokeWidth: 3,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(15),
                  dashPattern: const [20, 8],
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[100],
                    ),
                    width: model.imageViewSize.width,
                    height: model.imageViewSize.height,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 80,
                        ),
                        SizedBox(height: 30),
                        Text("Pick an image",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  ),
                ),
              )
            : AnimatedContainer(
                width: model.imageViewSize.width,
                height: model.imageViewSize.height,
                duration: model.animationDuration,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: MemoryImage(
                      model.pickedImageUint8List, // ?? Uint8List(10),
                    ),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.transparent,
                ),
              ),
        const SizedBox(height: 100),
        _PredictionOutputBox(model),
      ],
    );
  }
}

class _PredictionOutputBox extends StatelessWidget {
  final HomeScreenViewModel model;
  _PredictionOutputBox(this.model, {Key? key}) : super(key: key);

  List<Widget> _getTopPredictionsWidgets() {
    List<Widget> _widgets = [const SizedBox(width: 15)];
    for (String prediction in model.topPredictions) {
      prediction.replaceFirst('_', " ");
      _widgets.add(TextButton(
        style: _buttonStyle,
        onPressed: () {},
        child: Text(
          prediction,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ));
      _widgets.add(const SizedBox(width: 15));
    }
    return _widgets;
  }

  final ButtonStyle _buttonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
    padding: MaterialStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    ),
    elevation: MaterialStateProperty.all<double>(5),
    shape: MaterialStateProperty.all<OutlinedBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final TrainingState _ts = model.trainingState;
    return AnimatedContainer(
      margin: model.predictionViewEdgeInsets,
      duration: model.animationDuration,
      child: _ts != TrainingState.result
          ? const SizedBox()
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Prediction is ${model.prediction}",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // TextButton(
                //   style: _buttonStyle.copyWith(
                //     padding: MaterialStateProperty.all<EdgeInsets>(
                //       const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                //     ),
                //   ),
                //   onPressed: () {},
                //   child: Text(
                //     "Prediction is ${model.prediction}",
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontSize: 20,
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 70),
                const Text(
                  "Top Predictions",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _getTopPredictionsWidgets(),
                ),
                const SizedBox(height: 150),
                IconButton(
                  onPressed: model.clearPrediction,
                  hoverColor: Colors.red,
                  splashRadius: 20,
                  padding: EdgeInsets.all(10),
                  icon: Icon(Icons.clear),
                ),
                // TextButton(
                //   style: _buttonStyle.copyWith(
                //     backgroundColor:
                //         MaterialStateProperty.all<Color>(Colors.red),
                //   ),
                //   onPressed: model.clearPrediction,
                //   child: const Text(
                //     "Clear",
                //     style: TextStyle(
                //       fontSize: 15,
                //       color: Colors.white,
                //     ),
                //   ),
                // ),
              ],
            ),
    );
  }
}

class _PlotGraphButton extends StatelessWidget {
  final HomeScreenViewModel model;
  const _PlotGraphButton(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: model.isModelUntrained
          ? null
          : () async {
              await model.plotGraph();
            },
      icon: const Icon(
        Icons.bar_chart_outlined,
      ),
    );
  }
}

class _TextToSpeechButton extends StatelessWidget {
  final HomeScreenViewModel model;
  const _TextToSpeechButton(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: model.isModelUntrained ? null : model.toggleTTS,
        icon: Icon(
          model.isTTSEnabled
              ? Icons.volume_up_outlined
              : Icons.volume_off_outlined,
          //color: model.isModelUntrained ? Colors.grey[400] : Colors.white,
        ));
  }
}

class _ModelButton extends StatelessWidget {
  final HomeScreenViewModel model;
  const _ModelButton(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: model.launchURL,
      child: Text(
        model.datasetName,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _TrainButton extends StatelessWidget {
  final HomeScreenViewModel model;

  const _TrainButton(this.model, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TrainingState _ts = model.trainingState;
    final IconData _iconData =
        _ts == TrainingState.untrained || _ts == TrainingState.unconnected
            ? Icons.play_circle_outline_rounded
            : Icons.replay_outlined;
    final bool _showLoadingIndicator =
        _ts == TrainingState.training || _ts == TrainingState.connecting;
    return TextButton.icon(
      onPressed: () => model.decideTrainButtonAction(),
      icon: _showLoadingIndicator
          ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.yellow),
              ),
            )
          : Icon(
              _iconData,
              color: Colors.white,
            ),
      label: Text(
        model.trainButtomText,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class _TrainingStateLED extends StatelessWidget {
  final TrainingState state;
  const _TrainingStateLED(this.state, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      switch (state) {
        case TrainingState.success:
          return Colors.lightGreenAccent;
        case TrainingState.result:
          return Colors.lightGreenAccent;
        case TrainingState.failed:
          return Colors.red;
        case TrainingState.training:
          return Colors.amber;
        case TrainingState.connecting:
          return Colors.amber;
        default:
          return Colors.grey;
      }
    }

    return Container(
      width: 7.5,
      height: 7.5,
      decoration: BoxDecoration(
        color: getColor(),
        shape: BoxShape.circle,
      ),
    );
  }
}
