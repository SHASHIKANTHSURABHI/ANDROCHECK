from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image
import os

app = Flask(__name__)
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

# Load the trained model (adjust the path to your model file)
model_path = 'C:/Users/Shashikanth/AndroidStudioProjects/shashi_surabhi/assets/models/resnet50_model_continued.keras'
model = tf.keras.models.load_model(model_path)

# Define the target image size (should match the input size used during training)
TARGET_SIZE = (224, 224)

@app.route('/predict_sperm_count', methods=['POST'])
def predict_sperm_count():
    if 'image' not in request.files:
        return jsonify({'success': False, 'message': 'No image file provided'}), 400

    image_file = request.files['image']
    temp_img_path = 'temp_image.jpg'  # Temporary storage for the uploaded image

    try:
        # Save the image temporarily
        image_file.save(temp_img_path)

        # Load and preprocess the image
        img = Image.open(temp_img_path).resize(TARGET_SIZE)
        img_array = np.array(img) / 255.0  # Normalize image
        img_array = np.expand_dims(img_array, axis=0)  # Expand dims to match model input

        # Make a prediction
        prediction = model.predict(img_array)
        sperm_count = prediction[0][0]  # Assuming single-value regression output

        # Round off the predicted sperm count
        rounded_sperm_count = round(sperm_count)

        # Return the response
        return jsonify({'success': True, 'sperm_count': rounded_sperm_count}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

    finally:
        # Clean up the temporary file
        if os.path.exists(temp_img_path):
            os.remove(temp_img_path)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5011)
