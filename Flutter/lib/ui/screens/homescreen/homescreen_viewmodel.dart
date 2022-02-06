import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_classification_flutter/services/locator/locator.dart';
import 'package:image_classification_flutter/services/router/router.gr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stacked/stacked.dart';
import 'package:http/http.dart' as http;
import 'package:text_to_speech/text_to_speech.dart';
import 'package:url_launcher/url_launcher.dart';

const String backendURLHost = 'http://127.0.0.1:5000';

class HomeScreenViewModel extends BaseViewModel {
  TrainingState? _trainingState;
  String _trainButtonText = "Connect";
  String _datasetName = "CIFAR 100";
  String _prediction = '';
  List<String> _topPredictions = [];
  bool _isImagePicked = false;
  bool _isTTSEnabled = false;
  late PickedFile _pickedImage;
  Uint8List _pickedImageUint8List = Uint8List(10);
  //late MediaInfo _pickedImage;
  Duration _animationDuration = const Duration(seconds: 1);
  Size _imageViewSize = const Size(450, 250);
  Size _predictionViewSize = const Size(200, 100);
  EdgeInsets _predictionViewEdgeInsets = const EdgeInsets.all(0);
  //Uint8List _pickedImageUint = "";
  TrainingState get trainingState => _trainingState ?? TrainingState.other;
  bool get isModelTraining => _trainingState == TrainingState.training;
  bool get isModelUntrained =>
      _trainingState == TrainingState.untrained ||
      _trainingState == TrainingState.unconnected ||
      _trainingState == TrainingState.failed;
  String get trainButtomText => _trainButtonText;
  String get datasetName => _datasetName;
  String get prediction => _prediction;
  List<String> get topPredictions => _topPredictions;
  bool get isImagePicked => _isImagePicked;
  bool get isTTSEnabled => _isTTSEnabled;
  PickedFile get pickedImage => _pickedImage;
  Uint8List get pickedImageUint8List => _pickedImageUint8List;
  //MediaInfo get pickedImage => _pickedImage;
  Duration get animationDuration => _animationDuration;
  Size get imageViewSize => _imageViewSize;
  EdgeInsets get predictionViewEdgeInsets => _predictionViewEdgeInsets;

  reload() {
    notifyListeners();
  }

  toggleTTS() {
    _isTTSEnabled = !_isTTSEnabled;
    notifyListeners();
  }

  void launchURL() async {
    final String _url = 'https://paperswithcode.com/dataset/cifar-100';
    if (!await launch(_url)) throw 'Could not launch $_url';
  }

  _resetViewsParams() {
    _imageViewSize = const Size(400, 250);
    _predictionViewSize = const Size(200, 100);
    _predictionViewEdgeInsets = const EdgeInsets.all(0);
    _isImagePicked = false;
  }

  _setViewsParams() {
    _imageViewSize = const Size(200, 150);
    _predictionViewSize = const Size(600, 500);
    _predictionViewEdgeInsets = const EdgeInsets.only(bottom: 0);
  }

  Future<http.Response> get(String uri) async {
    return await http.get(
      Uri.parse(uri),
    );
  }

  Future<http.Response> uploadPic(
      {String uri = "$backendURLHost/mlengine/predict"}) async {
    return await http.post(
      Uri.parse(uri),
      body: _pickedImageUint8List.toList(growable: false),
      encoding: utf8,
    );
  }

  Future pickImageFromUser() async {
    final PickedFile? image = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    _pickedImageUint8List = await image?.readAsBytes() ?? Uint8List(10);
    _isImagePicked = true;
    _pickedImage = image!;
    reload();
    final http.Response _response = await uploadPic();
    final Map<String, dynamic> _data = jsonDecode(_response.body);
    _prediction = _data['prediction'];
    _prediction = _prediction.replaceFirst(RegExp(r'_'), ' ');
    _topPredictions = List<String>.from(jsonDecode(_data['topPredictions']));
    updateTrainingState(TrainingState.result);
    _setViewsParams();
    reload();
    if (_isTTSEnabled) {
      TextToSpeech tts = TextToSpeech();
      tts.setRate(0.8);
      tts.setVolume(1);
      await tts.speak("It is a $_prediction");
    }
  }

  Future plotGraph() async {
    final http.Response _response =
        await http.get(Uri.parse('$backendURLHost/mlengine/model/plot-graph'));
  }

  void clearPrediction() {
    updateTrainingState(TrainingState.success);
    _resetViewsParams();
    _prediction = '';
    _topPredictions = [];
    reload();
  }

  void updateTrainingState(TrainingState state) {
    _trainingState = state;
    if (state == TrainingState.untrained) {
      _trainButtonText = "Train";
    } else if (state == TrainingState.connecting) {
      _trainButtonText = "Connecting";
    } else if (state == TrainingState.training) {
      _trainButtonText = "Training";
    } else if (state == TrainingState.success) {
      _trainButtonText = "Retrain";
    } else if (state == TrainingState.failed) {
      _trainButtonText = "Retry";
    } else if (state == TrainingState.unconnected) {
      _trainButtonText = "Connect";
    }
  }

  Future trainTensorModel({bool retrain = false}) async {
    _resetViewsParams();
    updateTrainingState(TrainingState.training);
    reload();
    final String queryString = retrain ? '?retrain=true' : '';
    final http.Response _response = await http.get(
        Uri.parse('$backendURLHost/mlengine/model/train-model' + queryString));
    final Map<String, dynamic> _responseBody = jsonDecode(_response.body);
    if (_responseBody['result'] == true &&
        _responseBody['isModelTrained'] == true) {
      updateTrainingState(TrainingState.success);
    } else {
      updateTrainingState(TrainingState.failed);
    }
    reload();
  }

  Future setupBackend() async {
    updateTrainingState(TrainingState.connecting);
    reload();
    final http.Response _response =
        await http.get(Uri.parse('$backendURLHost/autosetup'));
    final Map<String, dynamic> _result = jsonDecode(_response.body);
    if (_result['result'] == true) {
      if (_result['isModelTrained'] == true) {
        updateTrainingState(TrainingState.success);
      } else {
        updateTrainingState(TrainingState.untrained);
      }
    } else {
      updateTrainingState(TrainingState.failed);
    }
    reload();
  }

  Future decideTrainButtonAction() async {
    if (_trainingState == TrainingState.unconnected ||
        _trainingState == TrainingState.failed) {
      await setupBackend();
    } else if (_trainingState == TrainingState.untrained) {
      await trainTensorModel();
    } else if (_trainingState == TrainingState.success ||
        _trainingState == TrainingState.result) {
      await trainTensorModel(retrain: true);
    }
  }

  void navigateToDatasetScreen() {
    locator<PageRouter>().navigate(const DatasetScreenRoute());
  }

  Future<void> onModelReady() async {
    _trainingState = TrainingState.unconnected;
  }
}

enum TrainingState {
  unconnected,
  connecting,
  untrained,
  training,
  success,
  result,
  failed,
  other,
}
