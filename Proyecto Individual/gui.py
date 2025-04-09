import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import quadrants

IMAGE_PATH = "image.jpg"  # Ruta de la imagen original

def update_quadrant(quadrant_entry, quadrant_label):
    """
    Función para actualizar la imagen del cuadrante seleccionado.
    """
    try:
        q_num = int(quadrant_entry.get())
        quadrant_img = quadrants.extract_quadrant(IMAGE_PATH, q_num)
        
        quadrant_img_tk = ImageTk.PhotoImage(quadrant_img)
        quadrant_label.config(image=quadrant_img_tk)
        quadrant_label.image = quadrant_img_tk
        
        # Opcional: Guardar el cuadrante en archivos si se requiere
        quadrants.save_quadrant_files(quadrant_img)
    except Exception as e:
        messagebox.showerror("Error", str(e))

def run_gui():
    """
    Crea y ejecuta la interfaz gráfica.
    """
    root = tk.Tk()
    root.title("Interpolación Bilineal")

    # Cargar y mostrar la imagen original
    try:
        original_img = Image.open(IMAGE_PATH).convert('L')
        original_img_tk = ImageTk.PhotoImage(original_img)
        original_label = tk.Label(root, image=original_img_tk)
        original_label.pack(padx=10, pady=10)
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo cargar la imagen: {e}")

    # Marco de control para seleccionar el cuadrante
    control_frame = tk.Frame(root)
    control_frame.pack(padx=10, pady=10)

    tk.Label(control_frame, text="Número de cuadrante (1-16):").grid(row=0, column=0, padx=5)
    quadrant_entry = tk.Entry(control_frame, width=5)
    quadrant_entry.grid(row=0, column=1, padx=5)

    select_button = tk.Button(control_frame, text="Mostrar Cuadrante", 
                              command=lambda: update_quadrant(quadrant_entry, quadrant_label))
    select_button.grid(row=0, column=2, padx=5)

    # Label para mostrar el cuadrante extraído
    quadrant_label = tk.Label(root)
    quadrant_label.pack(padx=10, pady=10)

    root.mainloop()

if __name__ == "__main__":
    run_gui()
