import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import bil
import quadrants
import subprocess

IMAGE_PATH = "image.jpg"   # Ruta de la imagen original
BIL_PATH = "output.jpg"    # Ruta de la imagen interpolada

def update_quadrant(quadrant_entry, quadrant_display):
    try:
        q_num = int(quadrant_entry.get())
        # Se extrae el cuadrante usando la función del módulo quadrants
        quadrant_img = quadrants.extract_quadrant(IMAGE_PATH, q_num)
        quadrant_img_tk = ImageTk.PhotoImage(quadrant_img)
        quadrant_display.config(image=quadrant_img_tk)
        quadrant_display.image = quadrant_img_tk
        quadrants.save_quadrant_files(quadrant_img)
    except Exception as e:
        messagebox.showerror("Error", "Debe escribir un número entre 1 y 16")

def bilinear_interp():
    try:
        # Compilación, enlace y ejecución del código ensamblador
        subprocess.run(["nasm", "-felf64", "-o", "bilinear.o", "bilinear.asm"], check=True)
        subprocess.run(["ld", "-o", "bilinear", "bilinear.o"], check=True)
        subprocess.run(["./bilinear"], check=True)
        bil.bilinear()
        messagebox.showinfo("Interpolación", "Interpolación realizada con éxito")
    except Exception as e:
        messagebox.showerror("Error", str(e))
        
def show_bil(interpolated_label):
    try:
        bilinear_img = Image.open(BIL_PATH)
        # Se ajusta el tamaño máximo para que se acomode al espacio disponible
        max_width, max_height = 400, 400
        bilinear_img.thumbnail((max_width, max_height))
        bilinear_img_tk = ImageTk.PhotoImage(bilinear_img)
        interpolated_label.config(image=bilinear_img_tk)
        interpolated_label.image = bilinear_img_tk
    except Exception as e:
        messagebox.showerror("Error", str(e))
        
def run_gui():
    root = tk.Tk()
    root.title("Interpolación Bilineal")
    root.minsize(800, 600)
    
    # --- FRAME SUPERIOR ---
    
    top_frame = tk.Frame(root)
    top_frame.pack(side="top", fill="both", expand=True, padx=10, pady=10)
    
    # Área de imagen original: se ubica en la parte izquierda
    original_frame = tk.Frame(top_frame)
    original_frame.pack(side="left", padx=10, pady=10)
    try:
        original_img = Image.open(IMAGE_PATH).convert('L')
        original_img_tk = ImageTk.PhotoImage(original_img)
        original_label = tk.Label(original_frame, image=original_img_tk)
        original_label.image = original_img_tk
        original_label.pack()
    except Exception as e:
        messagebox.showerror("Error", f"No se pudo cargar la imagen original: {e}")
    
    # Área de la imagen interpolada: 
    interpolated_frame = tk.Frame(top_frame)
    interpolated_frame.pack(side="right", padx=10, pady=10, fill="both", expand=True)
    
    interpolated_label = tk.Label(interpolated_frame)
    interpolated_label.pack(padx=10, pady=10)
    
    # Botones para la interpolación
    interp_controls = tk.Frame(interpolated_frame)
    interp_controls.pack(pady=5)
    interp_button = tk.Button(interp_controls, text="Realizar Interpolación", command=bilinear_interp)
    interp_button.pack(side="left", padx=5)
    show_button = tk.Button(interp_controls, text="Mostrar imagen interpolada", 
                              command=lambda: show_bil(interpolated_label))
    show_button.pack(side="left", padx=5)
    
    # --- FRAME INFERIOR ---
    bottom_frame = tk.Frame(root)
    bottom_frame.pack(side="top", fill="x", padx=10, pady=10)
    
    # Label para mostrar el cuadrante extraído
    quadrant_display = tk.Label(bottom_frame)
    quadrant_display.pack(pady=5)
    
    quadrant_controls = tk.Frame(bottom_frame)
    quadrant_controls.pack(pady=5)
    tk.Label(quadrant_controls, text="Número de cuadrante (1-16):").pack(side="left", padx=5)
    quadrant_entry = tk.Entry(quadrant_controls, width=5)
    quadrant_entry.pack(side="left", padx=5)
    select_button = tk.Button(quadrant_controls, text="Mostrar Cuadrante",
                                command=lambda: update_quadrant(quadrant_entry, quadrant_display))
    select_button.pack(side="left", padx=5)
    
    root.mainloop()

if __name__ == "__main__":
    run_gui()

