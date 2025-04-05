from PIL import Image
import struct

def display_quadrant_image(img_file):
    # Abrir el archivo .img en modo binario
    with open(img_file, "rb") as f:
        # Leer el encabezado: 4 bytes para el ancho y 4 bytes para el alto (little-endian)
        header = f.read(8)
        width, height = struct.unpack("<II", header)
        # Leer los datos de píxeles
        pixel_data = f.read()

    # Crear la imagen a partir de los datos: 'L' indica escala de grises
    img = Image.frombytes("L", (width, height), pixel_data)
    # Mostrar la imagen en pantalla
    img.show()

if __name__ == "__main__":
    # Asegúrate de que 'salida.img' sea el archivo generado previamente
    display_quadrant_image("salida.img")
