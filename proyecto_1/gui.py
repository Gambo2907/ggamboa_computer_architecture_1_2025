import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import bil
import quadrants

IMAGE_PATH = "image.jpg"  # Ruta de la imagen original
BIL_PATH = "output.jpg"

def update_quadrant(quadrant_entry, quadrant_label):
    try:
        q_num = int(quadrant_entry.get())
        # Supongamos que extract_quadrant devuelve una imagen PIL
        quadrant_img = quadrants.extract_quadrant(IMAGE_PATH, q_num)
        quadrant_img_tk = ImageTk.PhotoImage(quadrant_img)
        quadrant_label.config(image=quadrant_img_tk)
        quadrant_label.image = quadrant_img_tk
        quadrants.save_quadrant_files(quadrant_img)
    except Exception as e:
        messagebox.showerror("Error", "Debe escribir un número entre 1 y 16")

def bilinear_interp():
    try:
        # Ejecutar comandos de ensamblado y enlace
        import subprocess
        subprocess.run(["nasm", "-felf64", "-o", "bilinear.o", "bilinear.asm"], check=True)
        subprocess.run(["ld", "-o", "bilinear", "bilinear.o"], check=True)
        subprocess.run(["./bilinear"], check=True)
        bil.bilinear() 
        messagebox.showinfo("Interpolación","Interpolación Realizada con éxito")
    except Exception as e:
        messagebox.showerror("Error", str(e))
        
def show_bil(bilinear_label):
    try:
        bilinear_img = Image.open(BIL_PATH)
        bilinear_img_tk = ImageTk.PhotoImage(bilinear_img)
        bilinear_label.config(image=bilinear_img_tk)
        bilinear_label.image = bilinear_img_tk
    except Exception as e:
        messagebox.showerror("Error", str(e))
        
def run_gui():
    root = tk.Tk()
    root.title("Interpolación Bilineal")

    # Crear un frame para la imagen original y el control del cuadrante
    top_frame = tk.Frame(root)
    top_frame.pack(side="top", fill="x", padx=10, pady=10)

    # Mostrar la imagen original
    try:
        from PIL import Image
        original_img = Image.open(IMAGE_PATH).convert('L')
        original_img_tk = ImageTk.PhotoImage(original_img)
        original_label = tk.Label(top_frame, image=original_img_tk)
        original_label.image = original_img_tk
        original_label.pack(side="left", padx=10)
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo cargar la imagen: {e}")

    # Panel de control para el cuadrante
    quadrant_frame = tk.Frame(top_frame)
    quadrant_frame.pack(side="left", padx=10)
    tk.Label(quadrant_frame, text="Número de cuadrante (1-16):").grid(row=0, column=0, padx=5, pady=5)
    quadrant_entry = tk.Entry(quadrant_frame, width=5)
    quadrant_entry.grid(row=0, column=1, padx=5, pady=5)
    quadrant_label = tk.Label(quadrant_frame)  # Label para mostrar el cuadrante extraído
    quadrant_label.grid(row=1, column=0, columnspan=2, padx=5, pady=5)
    select_button = tk.Button(quadrant_frame, text="Mostrar Cuadrante", 
                                command=lambda: update_quadrant(quadrant_entry, quadrant_label))
    select_button.grid(row=2, column=0, columnspan=2, padx=5, pady=5)

    # Crear otro frame para la interpolación y su control
    bottom_frame = tk.Frame(root)
    bottom_frame.pack(side="top", fill="both", expand=True, padx=10, pady=10)
    interp_button = tk.Button(bottom_frame, text="Realizar Interpolación", command=bilinear_interp)
    interp_button.pack(side="left", padx=5, pady=5)
    # Label para mostrar la imagen interpolada
    bilinear_label = tk.Label(bottom_frame)
    bilinear_label.pack(side="left", padx=5, pady=5)
    show_button = tk.Button(bottom_frame, text="Mostrar imagen interpolada", 
                              command=lambda: show_bil(bilinear_label))
    show_button.pack(side="left", padx=5, pady=5)

    root.mainloop()

if __name__ == "__main__":
    run_gui()

