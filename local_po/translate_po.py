#!/usr/bin/env python3
import argparse
import os
import logging
import csv
import deepl
from polib import pofile

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

    def upload_glossary_from_csv(self, csv_path, source_lang="EN", target_lang="SV"):
        entries = {}
        with open(csv_path, newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                entries[row['source']] = row['target']

        glossary = self.translator.create_glossary(
            name=f"cli_glossary_{source_lang}_{target_lang}",
            source_lang=source_lang,
            target_lang=target_lang,
            entries=entries
        )
        self.glossary_id = glossary.glossary_id
        logger.info(f"Glossary created id={self.glossary_id}, entries={len(entries)})")

    def translate_po_file(self, po_path, target_lang="SV", source_lang="EN"):
        po = pofile(po_path)
        to_translate = [e.msgid for e in po if not e.msgstr]

        if not to_translate:
            logger.info(f"No untranslated entries in {po_path}")
            return 0

        translated_texts = []
        batch_size = 50

        for i in range(0, len(to_translate), batch_size):
            batch = to_translate[i:i + batch_size]
            if self.glossary_id:
                res = self.translator.translate_text(
                    batch, target_lang=target_lang,source_lang=source_lang,glossary=self.glossary_id
                )
            else:
                res = self.translator.translate_text(batch, target_lang=target_lang)

            if isinstance(res, list):
                translated_texts.extend([r.text for r in res])
            else:
                translated_texts.append(res.text)

        idx = 0
        for entry in po:
            if not entry.msgstr:
                entry.msgstr = translated_texts[idx]
                idx += 1

        po.save(po_path)
        logger.info(f"Translated {len(to_translate)} strings → {po_path}")
        return len(to_translate)


def main():
    parser = argparse.ArgumentParser(description="Translate .po files with DeepL")
    parser.add_argument(
        "-l", "--language",
        default="sv",
        help="Target language (default: sv)"
    )
    parser.add_argument(
        "-g", "--glossary",
        help="CSV glossary file with 'source' and 'target' columns"
    )
    parser.add_argument(
        "po_files",
        nargs="+",
        help=".po files to translate (shell-expanded wildcard supported)"
    )
    parser.add_argument(
        "--deepl-key",
        default=os.environ.get("DEEPL_AUTH_KEY"),
        help="DeepL API key (or set DEEPL_AUTH_KEY env var)"
    )
    args = parser.parse_args()

    try:
        translator = DeepLTranslator(args.deepl_key)
        if args.glossary:
            translator.upload_glossary_from_csv(
                args.glossary, source_lang="EN", target_lang=args.language.upper()
            )

        total_translated = 0
        for po_file in args.po_files:
            total_translated += translator.translate_po_file(
                po_file, target_lang=args.language.upper()
            )

        logger.info(f"Done! Translated total {total_translated} strings across {len(args.po_files)} file(s).")

    except Exception as e:
        logger.error(f"Error: {e}")
        return 1
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
