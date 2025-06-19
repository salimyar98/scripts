# Предварительно необходимо установить libavif - brew install libavif

import os
import subprocess
import cairosvg


def convert_svg_to_avif(svg_path, avif_path):
    png_temp_path = avif_path.replace(".avif", ".png")
    try:
        cairosvg.svg2png(url=svg_path, write_to=png_temp_path)
        print(f"SVG файл {svg_path} успешно конвертирован в PNG {png_temp_path}.")
    except Exception as e:
        print(f"Ошибка при конвертации SVG в PNG: {e}")
        return
    try:
        subprocess.run(["avifenc", png_temp_path, avif_path], check=True)
        print(f"PNG файл {png_temp_path} успешно конвертирован в AVIF {avif_path}.")
    except subprocess.CalledProcessError as e:
        print(f"Ошибка при конвертации PNG в AVIF: {e}")
        return
    if os.path.exists(png_temp_path):
        os.remove(png_temp_path)
        print(f"Временный файл {png_temp_path} удален.")


def convert_all_svgs_in_folder(input_folder, output_folder):
    for file_name in os.listdir(input_folder):
        if file_name.lower().endswith(".svg"):
            svg_path = os.path.join(input_folder, file_name)
            avif_path = os.path.join(output_folder, file_name.replace(".svg", ".avif"))
            convert_svg_to_avif(svg_path, avif_path)


input_folder = "/downloads/bank_logo"  # Путь к оригиналам в svg
output_folder = "downloads/bank_logo_avif"  # Путь к выходным файлам

if not os.path.exists(output_folder):
    os.makedirs(output_folder)

convert_all_svgs_in_folder(input_folder, output_folder)
