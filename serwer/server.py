from flask import Flask, request, jsonify
import werkzeug


import tensorflow as tf
import numpy as np
from PIL import Image

app = Flask(__name__)


@app.route('/upload', methods=["POST"])
def upload():
    if request.method == "POST":
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)
        print("\nReceived image File name : " + imagefile.filename)
        imagefile.save("./uploadedimages/skinlesion.jpg")
        labels = ['Benign', 'Malignant']
        model = TensorflowLiteClassificationModel("../serwer/modelLAST22.tflite", labels, 160)
        (label, probability) = model.run_from_filepath("../serwer/uploadedimages/skinlesion.jpg")
        print(f"Label: {label}, Probability: {probability}")
        return jsonify({
            "message": f"{probability}",
        })



class TensorflowLiteClassificationModel:
    def __init__(self, model_path, labels, image_size=160):
        self.interpreter = tf.lite.Interpreter(model_path=model_path)
        self.interpreter.allocate_tensors()
        self._input_details = self.interpreter.get_input_details()
        self._output_details = self.interpreter.get_output_details()
        self.labels = labels
        self.image_size=image_size

    def run_from_filepath(self, image_path):
        input_data_type = self._input_details[0]["dtype"]
        image = np.array(Image.open(image_path).resize((self.image_size, self.image_size)), dtype=input_data_type)
        if input_data_type == np.float32:
            image = image / 255.

        if image.shape == (1, 160, 160):
            image = np.stack(image*3, axis=0)

        return self.run(image)

    def run(self, image):
        """
        args:
          image: a (1, image_size, image_size, 3) np.array

        Returns list of [Label, Probability], of type List<str, float>
        """

        image = np.expand_dims(image, axis=0)
        self.interpreter.set_tensor(self._input_details[0]["index"], image)
        self.interpreter.invoke()
        tflite_interpreter_output = self.interpreter.get_tensor(self._output_details[0]["index"])
        probabilities = np.array(tflite_interpreter_output[0])

        # create list of ["label", probability], ordered descending probability
        label_to_probabilities = []
        for i, probability in enumerate(probabilities):
            label_to_probabilities.append([self.labels[i], float(probability)])
        return sorted(label_to_probabilities, key=lambda element: element[1])
    

if __name__ == "__main__":
    app.run(debug=True, port=4000)

