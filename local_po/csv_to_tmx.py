#!/usr/bin/env python3
# ::INSTRUCTIONS::
#jakob@odooutv18:~/weblatetools/local_po$ python3 csv_to_tmx.py glossary.csv glossary.tmx en sv
#Klart! glossary.tmx skapad med 2468 par

import csv
import sys
import argparse
from xml.etree import ElementTree as ET
from xml.dom import minidom

parser = argparse.ArgumentParser(description='Konvertera CSV till TMX')
parser.add_argument('input_csv', help='Inkommande CSV-fil')
parser.add_argument('output_tmx', help='Utfil TMX')
parser.add_argument('src_lang', default='en', nargs='?', help='Källspråk (default: en)')
parser.add_argument('tgt_lang', default='sv', nargs='?', help='Målspråk (default: sv)')

args = parser.parse_args()

tmx = ET.Element('tmx', version='1.4')
header = ET.SubElement(tmx, 'header', srclang=args.src_lang,
                       adminlang='en-us', datatype='plaintext',
                       segtype='sentence', oencoding='UTF-8')
body = ET.SubElement(tmx, 'body')

try:
    with open(args.input_csv, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row_num, row in enumerate(reader, 1):
            if len(row) >= 2 and row[0].strip() and row[1].strip():
                tu = ET.SubElement(body, 'tu')
                src_tuv = ET.SubElement(tu, 'tuv', xml_lang=args.src_lang)
                src_seg = ET.SubElement(src_tuv, 'seg')
                src_seg.text = row[0].strip()
                
                tgt_tuv = ET.SubElement(tu, 'tuv', xml_lang=args.tgt_lang)
                tgt_seg = ET.SubElement(tgt_tuv, 'seg')
                tgt_seg.text = row[1].strip()
            elif len(row) < 2:
                print(f"Varning: Rad {row_num} har för få kolumner", file=sys.stderr)
except FileNotFoundError:
    print(f"Fel: Hittar inte '{args.input_csv}'", file=sys.stderr)
    sys.exit(1)

xml_str = minidom.parseString(ET.tostring(tmx, encoding='unicode')).toprettyxml(indent='  ')
with open(args.output_tmx, 'w', encoding='utf-8') as f:
    f.write(xml_str)

print(f"Klart! {args.output_tmx} skapad med {len(body)} par")
