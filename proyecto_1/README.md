# Proyecto Individual - Desarrollo de una aplicación para la generación de gráficos y texto

Herramientas utilizadas:
1. Python para la realización del framework, la selección del cuadrante y la conversión a .jpg del .img de salida de la interpolación, debe tener instalado además tkinter y numpy.
2. Se utiliza el set de instrucciones x86 para la realización del código en ensamblador de la interpolación bilineal, se utiliza NASM en linux.

Instrucciones de uso:
1. Se corre el archivo main.py para visualizar el framework completo. Abra una terminal en el folder donde descargó el proyecto, y escriba lo siguiente para correr el programa: python3 main.py
Se abrirá el programa y encontrará tres botones y la imagen original que tiene dimensiones de 400x400.
2. Encontrará un cuadro de texto para escoger el cuadrante que quiera interpolar (1 al 16), luego de escribir el número del cuadrante escogido se selecciona el botón de "Mostrar cuadrante", el cuadrante tiene dimensiones 100x100.
3. Luego seleccione el botón de "Realizar Interpolación", se mostrará un mensaje que detalla la realización correcta de la interpolación.
4. Finalmente para mostrar la imagen interpolada seleccione el botón "Mostrar Imagen Interpolada". Mostrará en patalla la imagen interpolada con dimensiones 200x200.
