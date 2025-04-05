from PIL import Image
import struct

def extract_quadrant(image_path, quadrant_number):
    """
    Extrae y retorna el cuadrante especificado (1-16) de la imagen en escala de grises.
    """
    # Abrir la imagen y convertir a escala de grises
    img = Image.open(image_path).convert('L')
    width, height = img.size

    # Calcular dimensiones de cada cuadrante en una grilla 4x4
    quadrant_width = width // 4
    quadrant_height = height // 4

    if quadrant_number < 1 or quadrant_number > 16:
        raise ValueError("El número de cuadrante debe estar entre 1 y 16.")

    # Determinar fila y columna (índice base 0)
    quadrant_index = quadrant_number - 1
    row = quadrant_index // 4
    col = quadrant_index % 4

    # Coordenadas del cuadrante
    left = col * quadrant_width
    upper = row * quadrant_height
    right = left + quadrant_width
    lower = upper + quadrant_height

    # Extraer el cuadrante
    quadrant_img = img.crop((left, upper, right, lower))
    return quadrant_img

def save_quadrant_files(quadrant_img, output_img="salida.img", output_txt="output.txt"):
    """
    Guarda el cuadrante en un archivo binario (.img) con encabezado de ancho y alto
    y en un archivo de texto (.txt) con los valores de píxeles.
    """
    width, height = quadrant_img.size
    pixels = list(quadrant_img.getdata())

    # Guardar valores de píxeles en un archivo de texto
    with open(output_txt, "w") as f:
        for i in range(height):
            row_pixels = pixels[i * width:(i + 1) * width]
            f.write(" ".join(str(pixel) for pixel in row_pixels) + "\n")

    # Guardar la imagen en un archivo binario (.img)
    with open(output_img, "wb") as f:
        # Encabezado: ancho y alto (4 bytes cada uno, little-endian)
        f.write(struct.pack("<II", width, height))
        # Datos de píxeles (cada píxel es un byte)
        f.write(quadrant_img.tobytes())

