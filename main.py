from PIL import Image
import struct

def save_quadrant_grayscale(quadrant_number):
    # Ruta de la imagen y nombre del archivo de salida definidos en el código
    image_path = "image.jpg"  
    output_img = "salida.img"             # Archivo de salida con extensión .img

    # Abrir la imagen y convertirla a escala de grises ("L")
    img = Image.open(image_path).convert('L')
    width, height = img.size

    # Calcular dimensiones de cada cuadrante (grilla 4x4)
    quadrant_width = width // 4
    quadrant_height = height // 4

    # Verificar que el número de cuadrante es válido
    if quadrant_number < 1 or quadrant_number > 16:
        print("El número de cuadrante debe estar entre 1 y 16.")
        return

    # Calcular la fila y columna del cuadrante seleccionado
    quadrant_index = quadrant_number - 1  # Ajuste a índice 0
    row = quadrant_index // 4
    col = quadrant_index % 4

    # Coordenadas del cuadrante
    left = col * quadrant_width
    upper = row * quadrant_height
    right = left + quadrant_width
    lower = upper + quadrant_height

    # Extraer el cuadrante usando crop()
    quadrant_img = img.crop((left, upper, right, lower))

    # Guardar el cuadrante en un archivo binario .img
    with open(output_img, "wb") as f:
        # Escribir un encabezado con el ancho y alto del cuadrante (4 bytes cada uno, little-endian)
        f.write(struct.pack("<II", quadrant_width, quadrant_height))
        # Escribir los datos de los píxeles (cada píxel es un byte con valores de 0 a 255)
        f.write(quadrant_img.tobytes())

    print(f"Cuadrante {quadrant_number} guardado en '{output_img}'.")


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
    try:
        quadrant = int(input("Ingrese el número de cuadrante (1-16): "))
        save_quadrant_grayscale(quadrant)
    except ValueError:
        print("Por favor, ingrese un número válido.")

    display_quadrant_image("salida.img")