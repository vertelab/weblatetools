#!/usr/bin/env python3

import csv
import argparse
import glob
import os
import polib
import sys

def load_glossary(glossary_path):
    glossary = {}
    with open(glossary_path, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        # Förväntar sig kolumner source,target
        for row in reader:
            source = row['source'].strip()
            target = row['target'].strip()
            glossary[source] = target
    return glossary

def find_errors_in_po(po_path, glossary):
    """
    Scans a PO file and returns a list of tuples:
    (module name, expected word from dictionary, translation)

where the translation contains a wrongly translated word from the dictionary
(i.e., the word is expected to be present but is missing, or it is present but incorrect).
    """
    errors = []
    match = re.search(r'-(\w+)-([a-z]{2})\.po$', po_path)
    if match:
        modul = match.group(1)
        po = polib.pofile(po_path)
        for entry in po:
            for source_word, target_word in glossary.items():
                if not source_word in entry.msgid:
                    continue
                if target_word not in entry.msgstr:
                    if source_word in entry.msgstr:
                        errors.append((modul, f"{source_word}:{target_word}", f"{entry.msgstr} ({entry.msgid})"))
    return errors

def main():
    parser = argparse.ArgumentParser(description="Check glosssary use in PO-files")
    parser.add_argument('-g', '--glossary', required=True,
                        help='Glosssary in CSV-format columns source,target Target is in language')
    parser.add_argument('files', nargs='+',
                        help='List of PO-files to check (exampel: *.po)')

    args = parser.parse_args()

    glossary = load_glossary(args.glossary)

    for po_file in args.files:
        if not os.path.isfile(po_file):
            print(f"Warning: {po_file} missing", file=sys.stderr)
            continue
        errors = find_errors_in_po(po_file, glossary)
        for modul, expected_word, translation in errors:
            print(f"{modul}\t{expected_word}\t{translation}")

if __name__ == '__main__':
    main()
