#!/usr/bin/env python3

from polib import pofile
import argparse
import csv
import deepl
import glob
import logging
import os
import sys

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

class DeepLTranslator:
    def __init__(self, deepl_auth_key):
        if not deepl_auth_key:
            raise ValueError("DeepL API key required")
        self.translator = deepl.Translator(deepl_auth_key)
        self.glossary_id = None

    def upload_glossary(self, glossary, source_lang="EN", target_lang="SV"):
        self.translator.create_glossary(
            name=f"cli_glossary_{source_lang}_{target_lang}",
            source_lang=source_lang,
            target_lang=target_lang,
            entries={source: target for source,target in glossary.items()}
        )
        self.glossary_id = glossary.id
        logger.info(f"Glossary created id={self.glossary_id}, entries={len(glossary)})")

    def translate_glossary(self, new_glossary, target_lang="SV"):
        po = pofile(po_path)
        to_translate = [target for source,target in new_glossary if not target]

        if not to_translate:
            logger.info(f"No untranslated entries")
            return 0

        translated_texts = []
        batch_size = 50

        for i in range(0, len(to_translate), batch_size):
            batch = to_translate[i:i + batch_size]
            if self.glossary_id:
                res = self.translator.translate_text(
                    batch, target_lang=target_lang, glossary_id=self.glossary_id
                )
            else:
                res = self.translator.translate_text(batch, target_lang=target_lang)

            if isinstance(res, list):
                translated_texts.extend([r.text for r in res])
            else:
                translated_texts.append(res.text)

        idx = 0
        for source,target in new_glossary:
            if not target:
                new_glossary[idx] = (source,translated_texts[idx])
                idx += 1
        return new_glossary



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

def new_glossary_from_po(po_path, glossary, max_words):
    """
    Use Scans a PO file and returns a list of tuples:
        (module name, expected word from dictionary, translation)
    where the translation contains a wrongly translated word from the dictionary
        (i.e., the word is expected to be present but is missing, or it is present but incorrect).
    """
    new_glossary=[]
    match = re.search(r'-(\w+)-([a-z]{2})\.po$', po_path)
    if match:
        modul = match.group(1)
        po = polib.pofile(po_path)
        for entry in po:
            if len(entry.msgid.split(' '))>max_words:
                continue
            glossary_pair = (entry.msgid,'')
            for source_word, target_word in glossary.items():
                if source_word == entry.msgid:
                    glossary_pair=(entry.msgid,target)
                    break
            new_glossary.add(glossary_pair)
    return new_glossary

def main():
    parser = argparse.ArgumentParser(description="Merge words in po-file to a glosssary")
    parser.add_argument('-g', '--glossary', required=True,help='Glosssary in CSV-format columns source,target Target is in language')
    parser.add_argument('-m', '--max', default=3, help='Max number of words (default: 3)')
    parser.add_argument('-l', '--language', default='sv', help='Language (default: sv)')
    parser.add_argument('-t', '--translate', help='Translate new glossary items')
    parser.add_argument("--deepl-key",default=os.environ.get("DEEPL_AUTH_KEY"),
        help="DeepL API key (or set DEEPL_AUTH_KEY env var)"
    )
    parser.add_argument('files', nargs='+',help='List of PO-files to check (example: *.po)')

    args = parser.parse_args()
    glossary = load_glossary(args.glossary)

    for po_file in args.files:
        if not os.path.isfile(po_file):
            print(f"Warning: {po_file} missing", file=sys.stderr)
            continue
        new_glossary = new_glossary_from_po(po_file, glossary)
        if args.translate:
            try:
                translator = DeepLTranslator(args.deepl_key)
                if args.glossary:
                    translator.upload_glossary(
                        args.glossary, source_lang="EN", target_lang=args.language.upper()
                    )

                translator.translate_glossary(new_glossary, target_lang=args.language.upper())

            except Exception as e:
                logger.error(f"Error: {e}")
                return 1
            return 0
        print("source,target")
        print([f"source,target\n" for (source,target) in new_glossary.items()])


if __name__ == '__main__':
    main()
