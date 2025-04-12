import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
def bilinear():
    # Dimensiones conocidas
    height, width = 200, 200

    # Lee los datos crudos
    raw_data = np.fromfile("output.img", dtype=np.uint8)

    if raw_data.size != height * width:
        raise ValueError("El tamaño de los datos no coincide con los píxeles.")

    # Reorganiza en una matriz 2D (escala de grises)
    raw_data = raw_data.reshape((height, width))

    # Crea la imagen a partir de la matriz
    img = Image.fromarray(raw_data, mode="L")

    # Guarda como JPEG 
    img.save("output.jpg", "JPEG")





