import xml.etree.ElementTree as ET
from deep_translator import GoogleTranslator

def translate_xlf(file_path, output_path):
    translator = GoogleTranslator(source='en', target='es')

    tree = ET.parse(file_path)
    root = tree.getroot()
    for trans_unit in root.findall(".//trans-unit"):
        source = trans_unit.find("source")
        target = trans_unit.find("target")
        if source is not None and target is not None and target.text and target.text.strip() == "[NAB: NOT TRANSLATED]":
            source_text = source.text.strip()
            try:
                translated_text = translator.translate(source_text)
                target.text = translated_text
            except Exception as e:
                print(f"Error al traducir '{source_text}': {e}")

    tree.write(output_path, encoding='utf-8', xml_declaration=True)

# Uso del programa
input_file = "Translations\ModuloContrato.es-MX.xlf" # Cambia por la ruta de tu archivo de entrada
output_file = "ModuloContrato_translated.es-MX.xlf"  # Cambia por la ruta de salida
translate_xlf(input_file, output_file)

print("Traducción completa. Archivo actualizado guardado.")
