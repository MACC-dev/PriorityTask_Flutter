import tensorflow as tf
import numpy as np
import joblib

# Cargar el modelo entrenado
model = joblib.load('task_model.pkl')

# Crear una función de ejemplo para la conversión
def predict_example():
    example = np.array([[0, 2, 1]], dtype=np.float32)
    return model.predict(example)

# Convertir el modelo a TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_concrete_functions(
    [predict_example.get_concrete_function()], model
)
tflite_model = converter.convert()

# Guardar el modelo TFLite
with open('task_model.tflite', 'wb') as f:
    f.write(tflite_model)