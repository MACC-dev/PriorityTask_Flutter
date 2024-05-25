new_data = load_new_data() 
model.fit(new_data['X'], new_data['y'], epochs=10, batch_size=32)

converter = tf.lite.TFLiteConverter.from_keras_model(model)
updated_tflite_model = converter.convert()

with open('updated_task_priority_model.tflite', 'wb') as f:
    f.write(updated_tflite_model)