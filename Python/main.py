
from typing import Any
from flask import Flask, json, jsonify, Request, request
from flask_cors import CORS, cross_origin
import numpy as np
from tensorflow.keras import layers, models
from tensorflow.python.keras.engine import training
#from tensorflow.python.ops.gen_math_ops import cross
#import werkzeug
#from werkzeug.datastructures import FileStorage
from PIL import Image
import shutil

from tensorflow.python.ops.gen_math_ops import cross


class DatasetManager:

    isDatasetLoaded: bool
    training_data: list
    training_labels: list
    testing_data: list
    testing_labels: list
    training_data_len: int
    training_labels_len: int
    testing_data_len: int
    testing_labels_len: int
    metaData: list
    fine_labels: list
    coarse_labels: list
    class_names: list[str]

    def __init__(self):
        self.class_names = []
        self.isDatasetLoaded = False
        self.metaData, self.coarse_labels, self.fine_labels = [], [], []
        self.training_data, self.training_labels, self.testing_data, self.testing_labels = [], [], [], []
        self.training_data_len, self.training_labels_len, self.testing_data_len, self.testing_labels_len = 0, 0, 0, 0

    def details(self):
        return {
            "training_data": self.training_data_len,
            "testing_data": self.testing_data_len,
            "fine_labels": self.fine_labels,
            "fine_labels_len": len(self.fine_labels),
            "coarse_labels": self.coarse_labels,
            "coarse_labels_len": len(self.coarse_labels),
        }

    def status(self):
        return {
            "isDatasetLoaded": self.isDatasetLoaded
        }

    def addimage(self, img: Image):

        np_arr = np.array(img.convert('RGB'))

        pass

    def datasetParser(self, file):
        try:
            import pickle
            with open(file, 'rb')as fo:
                dict = pickle.load(fo, encoding='latin1')
            fo.close()
            return dict
        except:
            return False

    def conv1Dto2D(self, inp) -> np.array:
        result = []
        for i in inp:
            result.append(list([i]))
        return np.array(result)

    def saveDataset(self):
        try:
            pass
            return True
        except:
            return False

    def loadDataset(self, reload=False):
        if (self.isDatasetLoaded and not reload):
            return True
        try:
            trDS = self.datasetParser('./cifar-100-python/train')
            ttDS = self.datasetParser('./cifar-100-python/test')
            mtDS = self.datasetParser('./cifar-100-python/meta')
            self.training_data = trDS['data']
            self.training_data = self.training_data / 255.0
            self.training_data_len = len(self.training_data)
            training_labels = trDS['fine_labels']
            self.training_labels = self.conv1Dto2D(training_labels)
            self.training_labels_len = len(self.training_labels)
            self.testing_data = ttDS['data']
            self.testing_data = self.testing_data / 255.0
            self.testing_data_len = len(self.testing_data)
            testing_labels = ttDS['fine_labels']
            self.testing_labels = self.conv1Dto2D(testing_labels)
            self.testing_labels_len = len(self.testing_labels)
            self.training_data = self.training_data.reshape(
                self.training_data_len, 3, 32, 32).transpose(0, 2, 3, 1)
            self.testing_data = self.testing_data.reshape(
                self.testing_data_len, 3, 32, 32).transpose(0, 2, 3, 1)
            self.fine_labels = mtDS['fine_label_names']
            self.coarse_labels = mtDS['coarse_label_names']
            self.isDatasetLoaded = True
            return True
        except:
            self.isDatasetLoaded = False
            return False


class MLEngine:

    currentStatus: str
    isModelTrained: bool
    isModelSetupDone: bool
    model: models.Sequential
    loss: float
    accuracy: float
    currentImage: Image

    def __init__(self):
        self.isModelTrained = False
        self.isModelSetupDone = False
        self.loss = 0.0
        self.accuracy = 0.0
        self.currentStatus = "Untrained"
        self.history = None

    def loadSavedModel(self):
        try:
            self.model = models.load_model('./models/image-classifier.model')
            self.isModelSetupDone = True
            self.isModelTrained = True
            return True
        except:
            return False

    def saveModel(self) -> bool:
        try:
            cndn1 = self.model is not None
            cndn2 = self.isModelSetupDone and self.isModelTrained
            if(cndn1 and cndn2):
                self.model.save('./models/image-classifier.model')
                return True
            else:
                return False
        except:
            return False

    def status(self):
        return {
            "currentStatus": self.currentStatus,
            "loss": self.loss,
            "accuracy": self.accuracy,
        }

    def setupModel(self, reSetup=False):
        if self.isModelSetupDone and not reSetup:
            return True
        try:
            pd = 'valid'
            self.model = models.Sequential([
                layers.Conv2D(64, (2, 2), input_shape=(32, 32, 3),
                              strides=(2, 2), padding=pd),
                layers.MaxPooling2D(strides=(1, 1), padding=pd),
                layers.Conv2D(64, (2, 2), strides=(2, 2), padding=pd),
                layers.MaxPooling2D(strides=(1, 1), padding=pd),
                layers.Flatten(),
                layers.Dense(256, activation='relu'),
                layers.Dense(128, activation='relu'),
                layers.Dense(100, activation='softmax'),
            ])
            # self.model = models.Sequential([
            #     layers.Conv2D(64, (3, 3), activation='relu',
            #                   input_shape=(32, 32, 3)),
            #     layers.MaxPooling2D(2, 2),
            #     layers.Conv2D(64, (3, 3), activation='relu'),
            #     layers.MaxPooling2D(2, 2),
            #     layers.Flatten(),
            #     layers.Dense(512, activation='relu'),
            #     layers.Dense(100, activation='softmax')
            # ])
            self.isModelSetupDone = True
            return True
        except:
            return False

    def getAccLoss(self, retest=False):
        cndn1 = retest or self.loss == 0.0 or self.accuracy == 0.0
        cndn2 = mlEngine.isModelSetupDone and mlEngine.isModelTrained
        if cndn1 and cndn2:
            test_loss, test_acc = self.model.evaluate(
                datasetManager.testing_data, datasetManager.testing_labels)
            self.loss = test_loss
            self.accuracy = test_acc
            retest = True
            return {
                "result": True,
                "retest": retest,
                "loss": self.loss,
                "accuracy": self.accuracy,
            }
        else:
            return {
                "result": False,
                "retest": retest,
                "loss": self.loss,
                "accuracy": self.accuracy,
                "isModelReady": cndn2, }

    def trainModel(self, optimizer='adam', loss='sparse_categorical_crossentropy', epochs=15, retrain=False):

        if (not datasetManager.isDatasetLoaded) or (not self.isModelSetupDone):
            return False
        if (self.isModelTrained and not retrain):
            return True
        if retrain:
            epochs = 8
            self.isModelSetupDone = False
            result = self.setupModel(reSetup=True)
            if result is False:
                return False
        # try:
        self.model.compile(
            optimizer=optimizer, loss=loss, metrics=['accuracy'])
        self.history = self.model.fit(datasetManager.training_data, datasetManager.training_labels, epochs=epochs,
                                      validation_split=0.2)
        self.isModelTrained = True
        result = self.saveModel()
        return True

    def plotGraph(self):
        import matplotlib.pyplot as plt
        if self.history is None or self.isModelTrained is False:
            return False
        # try:

        # Accuracy
        print(self.history.history.keys())
        plt.plot(self.history.history['accuracy'])
        plt.plot(self.history.history['val_accuracy'])
        plt.title('Model accuracy')
        plt.ylabel('Accuracy')
        plt.xlabel('Epoch')
        plt.legend(['Train', 'Test'], loc='upper left')
        plt.show()

        # Loss
        plt.plot(self.history.history['loss'])
        plt.plot(self.history.history['val_loss'])
        plt.title('Model Loss')
        plt.ylabel('Loss')
        plt.xlabel('Epoch')
        plt.legend(['Train', 'Test'], loc='upper left')
        plt.show()

        return True
        #     return True
        # except:
        #     return False

    def predict(self, request_data):
        if not self.isModelTrained:
            return {"result": "false", "message": "Model not trained"}
        import io
        request_data = io.BytesIO(request_data)
        img = Image.open(request_data)
        img = img.resize((32, 32))
        np_arr = np.array(img.convert('RGB'))
        prediction = self.model.predict(np.array([np_arr])/255.0)
        # index = np.argmax(prediction)
        # label = datasetManager.fine_labels[index]
        # return {
        #     "result": "true",
        #     "prediction": label,
        # }
        prediction = prediction[0]
        result_ndarr = (-prediction).argsort()[:6]
        result_labels = [datasetManager.fine_labels[i]
                         for i in result_ndarr]
        prediction = result_labels[0]
        result_labels = json.dumps(result_labels[1:])
        return {
            "result": "true",
            "prediction": prediction,
            # "index": result_ndarr[0],
            "topPredictions": result_labels,
            # "topPredictionsIndex": result_ndarr[1:],

        }


datasetManager: DatasetManager
mlEngine: MLEngine

datasetManager = DatasetManager()
mlEngine = MLEngine()

app = Flask(__name__)

cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'


@app.route('/')
@cross_origin()
def main():
    return jsonify({
        "Status": "Server is running"
    })


@app.route('/status')
@cross_origin()
def status():
    mle_status = mlEngine.status()
    dsm_status = datasetManager.status()
    return jsonify({
        "ml_engine": {
            "name": "ML Engine",
            "status": mle_status,
        },
        "dataset_manager": {
            "name": "Dataset Manager",
            "status": dsm_status,
        }
    })


def _autoSetup():
    try:
        result = datasetManager.loadDataset()
        if result is False:
            return False
        result = mlEngine.loadSavedModel()
        if result is False:
            result = mlEngine.setupModel(reSetup=True)
            return result
        return True
    except:
        return False


@app.route('/autosetup')
@cross_origin()
def autosetup():
    result = _autoSetup()
    return jsonify({
        "result": result,
        "isDstasetLoaded": datasetManager.isDatasetLoaded,
        "isModelSetupDone": mlEngine.isModelSetupDone,
        "isModelTrained": mlEngine.isModelTrained,
    })


@app.route('/datasetmanager/dataset/load-saved')
@cross_origin()
def datasetmanager_dataset_loadsaved():
    if not datasetManager.isDatasetLoaded:
        result = datasetManager.loadDataset()
        if result:
            return jsonify({
                "result": "true",
                "isDatasetLoaded": str(datasetManager.isDatasetLoaded),
                "training_data_len": str(datasetManager.training_data_len),
                "testing_data_len": str(datasetManager.testing_data_len),
            })
    return jsonify({
        "result": "false",
        "isDatasetLoaded": str(datasetManager.isDatasetLoaded),
        "training_data_len": str(datasetManager.training_data_len),
        "testing_data_len": str(datasetManager.testing_data_len),
    })


@app.route('/datasetmanager/status/all')
@cross_origin()
def datasetmanager_status_all():
    return jsonify(datasetManager.status())


@app.route('/mlengine/status/all')
@cross_origin()
def mlengine_status_all():
    return jsonify(mlEngine.status())


@app.route('/mlengine/status/get-acc-loss')
@cross_origin()
def mlengine_status_getaccloss():
    retestArg = request.args['retest']
    retest = retestArg == 'true'
    return jsonify(mlEngine.getAccLoss(retest=retest))


@app.route('/mlengine/model/save-model')
@cross_origin()
def mlengine_model_savemodel():
    result = mlEngine.saveModel()
    return jsonify({
        "result": result,
    })


@app.route('/mlengine/model/load-saved-model')
@cross_origin()
def mlengine_model_loadsavedmodel():
    result = mlEngine.loadSavedModel()
    return jsonify({"result": result,
                    "isModelSetupDone": mlEngine.isModelSetupDone,
                    "isModelTrained": mlEngine.isModelTrained,
                    })


@app.route('/mlengine/model/setup')
@cross_origin()
def mlengine_model_setup():
    result = mlEngine.setupModel()
    return jsonify({
        "result": result
    })


@app.route('/mlengine/model/train-model')
@cross_origin()
def mlengine_model_trainmodel():
    retrainArg = request.args['retrain']
    retrain = retrainArg == 'true'
    result = mlEngine.trainModel(retrain=retrain)
    print(f"\nResult: {result}\n")
    return jsonify(
        {
            "result": result,
            "isDatasetLoaded": datasetManager.isDatasetLoaded,
            "isModelSetupDone": mlEngine.isModelSetupDone,
            "isModelTrained": mlEngine.isModelTrained,
        }
    )


@app.route('/mlengine/model/plot-graph')
@cross_origin()
def mlengine_model_plotgraph():
    result = mlEngine.plotGraph()
    return jsonify({
        "result": result,
        "isModelTrained": mlEngine.isModelTrained,
        "isHistoryNull": mlEngine.history is None,
    })


@app.route('/mlengine/predict', methods=['POST'])
@cross_origin()
def mlengine_predict():
    request_data = request.get_data(as_text=False)
    return jsonify(mlEngine.predict(request_data))


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
