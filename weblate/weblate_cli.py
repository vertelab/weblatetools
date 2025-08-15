#!/usr/bin/env python3
from polib import pofile
import argparse
import csv
import deepl
import fnmatch
import glob
import logging
import os
import sys
import wlc
import xml.etree.ElementTree as ET

# Configure logging
logging.basicConfig(level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class WeblateWLCClient:
    def __init__(self, base_url="https://translate.odoo.com/api/", api_token=None):
        if not api_token:
            logger.warning("No Weblate API token provided. Some operations may be restricted.")
        self.api_token = api_token
        self.client = wlc.Weblate(url=base_url, key=api_token)

    def list_projects(self):
        return self.client.get("projects/")

    def list_components(self, project_slug):
        return self.client.get(f"projects/{project_slug}/components/")

    def list_translations(self, project_slug, component_slug):
        return self.client.get(f"components/{project_slug}/{component_slug}/translations/")

    def list_all_project_slugs(self):
        return [p['slug'] for p in self.list_projects().get('results', [])]

    def list_component_slugs(self, project_slug):
        return [c['slug'] for c in self.list_components(project_slug).get('results', [])]

    def download_po_file(self, project_slug, component_slug, language_code, output_path):
        # Lägg till token i headern så att API tillåter hämtning
        headers = {'Accept': 'application/x-gettext'}
        if self.api_token:
            headers['Authorization'] = f'Token {self.api_token}'
        url = f"{self.client.url}translations/{project_slug}/{component_slug}/{language_code}/file/"
        r = self.client.session.get(url, headers=headers)
        r.raise_for_status()
        os.makedirs(os.path.dirname(output_path) or ".", exist_ok=True)
        with open(output_path, "wb") as f:
            f.write(r.content)
        logger.info(f"Downloaded: {output_path}")
        return output_path

    def download_glossary(self, project_slug, component_slug, language_code, file_type='tbx'):        
        # Lägg till token i headern så att API tillåter hämtning
        headers = {'Accept': 'application/x-gettext'}
        if self.api_token:
            headers['Authorization'] = f'Token {self.api_token}'
        url = f"{self.client.url}translations/{project_slug}/{component_slug}/{language_code}/file/"
        r = self.client.session.get(url, headers=headers)
        r.raise_for_status()
        with open('glossary.tbx', "wb") as f:
            f.write(r.content)
        if file_type == 'csv':
            self._convert_tbx_to_csv('glossary.tbx','glossary.csv',source_lang='en',target_lang=language_code)
            os.remove('glossary.tbx')
            logger.info(f"Downloaded: glossary.csv")
        else:
            logger.info(f"Downloaded: glossary.tbx")
        return 'glossary'

    def _convert_tbx_to_csv(self, tbx_path, csv_path, source_lang="en", target_lang="sv"):
        """
        Konverterar TBX (MARTIF XML) till CSV med kolumner 'source', 'target'
        """
        tree = ET.parse(tbx_path)
        root = tree.getroot()

        # TBX använder ofta XML-namnrymder, men vi kan matcha utan via .tag.endswith
        rows = []
        for term_entry in root.findall(".//termEntry"):
            src_term = None
            tgt_term = None
            for lang_set in term_entry.findall("langSet"):
                lang = lang_set.get("{http://www.w3.org/XML/1998/namespace}lang")
                term_elem = lang_set.find(".//term")
                if term_elem is not None:
                    if lang.lower() == source_lang.lower():
                        src_term = term_elem.text
                    elif lang.lower() == target_lang.lower():
                        tgt_term = term_elem.text
            if src_term and tgt_term:
                rows.append((src_term, tgt_term))

        # Skriv CSV
        with open(csv_path, "w", newline='', encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(["source", "target"])
            writer.writerows(rows)

    def upload_po_file(self, project_slug, component_slug, language_code, file_path, method='translate'):
        with open(file_path, "rb") as f:
            files = {"file": (os.path.basename(file_path), f, "application/x-gettext")}
            data = {"method": method}
            self.client.post(
                f"translations/{project_slug}/{component_slug}/{language_code}/file/",
                files=files, data=data
            )
        logger.info(f"Uploaded: {file_path}")

    def download_components_wildcard(self, proj_pattern='*', comp_pattern='*', lang='sv', output_dir='.'):
        downloaded = []
        for proj in fnmatch.filter(self.list_all_project_slugs(), proj_pattern):
            for comp in fnmatch.filter(self.list_component_slugs(proj), comp_pattern):
                filename = f"{proj}-{comp}-{lang}.po"
                path = os.path.join(output_dir, filename)
                try:
                    self.download_po_file(proj, comp, lang, path)
                    downloaded.append(path)
                except Exception as e:
                    logger.error(f"Error downloading {filename}: {e}")
        return downloaded

    def upload_files_wildcard(self, file_pattern='*.po', lang='sv', method='translate'):
        uploaded = []
        for fp in glob.glob(file_pattern):
            base = os.path.basename(fp).rsplit('.', 1)[0]
            parts = base.split('-')
            if len(parts) < 3:
                logger.warning(f"Skipping (bad format): {fp}")
                continue
            project = parts[0]
            file_lang = parts[-1]
            component = '-'.join(parts[1:-1])
            if file_lang != lang:
                logger.warning(f"Skipping {fp}, lang mismatch {file_lang} != {lang}")
                continue
            try:
                self.upload_po_file(project, component, file_lang, fp, method)
                uploaded.append(fp)
            except Exception as e:
                logger.error(f"Error uploading {fp}: {e}")
        return uploaded


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
        self.glossary_id = glossary.id
        logger.info(f"Glossary created id={self.glossary_id}, entries={len(entries)}")
        return self.glossary_id

    def translate_po_file(self, po_path, target_lang="SV"):
        po = pofile(po_path)
        to_translate = [e.msgid for e in po if not e.msgstr]
        if not to_translate:
            logger.info(f"No untranslated in {po_path}")
            return po_path
        translated_texts = []
        batch_size = 50
        for i in range(0, len(to_translate), batch_size):
            batch = to_translate[i:i+batch_size]
            if self.glossary_id:
                res = self.translator.translate_text_with_glossary(
                    batch, target_lang=target_lang, glossary_id=self.glossary_id
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
        logger.info(f"Translated and saved: {po_path}")
        return po_path


def deepl_command(client, deepl_key, proj_pat, comp_pat, lang, glossary_path=None):
    deepl_trans = DeepLTranslator(deepl_key)
    if glossary_path:
        deepl_trans.upload_glossary_from_csv(glossary_path, source_lang="EN", target_lang=lang.upper())
    files = client.download_components_wildcard(proj_pat, comp_pat, lang, output_dir='.')
    for po_file in files:
        translated_file = deepl_trans.translate_po_file(po_file, target_lang=lang.upper())
        base = os.path.basename(translated_file).rsplit('.', 1)[0]
        parts = base.split('-')
        project = parts[0]
        component = '-'.join(parts[1:-1])
        client.upload_po_file(project, component, lang, translated_file, method='translate')

def main():
    parser = argparse.ArgumentParser(description='CLI for Weblate .po management + DeepL')
    parser.add_argument('--token', '-t', default=os.environ.get('WEBLATE_TOKEN'))
    parser.add_argument('--url', '-u', default='https://translate.odoo.com/api/')
    parser.add_argument('--verbose', '-v', action='store_true')
    parser.add_argument(
        '-w', '--weblate',
        choices=['odoo', 'oca'],
        help='Select Weblate instance: "odoo" or "oca". Reads token from ODOO_API_KEY or OCA_API_KEY env vars.'
    )

    # Subcommands
    subs = parser.add_subparsers(dest='command')
    subs.add_parser('list-projects')
    lc = subs.add_parser('list-components')
    lc.add_argument('project')
    lt = subs.add_parser('list-translations')
    lt.add_argument('project')
    lt.add_argument('component')
    dl = subs.add_parser('download')
    dl.add_argument('-p', '--project', default='odoo-18')
    dl.add_argument('component')
    dl.add_argument('-l', '--language', default='sv')
    dl.add_argument('-o', '--output')
    ul = subs.add_parser('upload')
    ul.add_argument('--project', default='odoo-18')
    ul.add_argument('component')
    ul.add_argument('-l', '--language', default='sv')
    ul.add_argument('-f', '--file', default='sv.po')
    ul.add_argument('--method', choices=['translate', 'source', 'suggest', 'approve'], default='translate')
    dw = subs.add_parser('download-multi')
    dw.add_argument('-p', '--project', default='*')
    dw.add_argument('-c', '--component', default='*')
    dw.add_argument('-l', '--language', default='sv')
    dw.add_argument('-o', '--output-dir', default='.')
    uw = subs.add_parser('upload-multi')
    uw.add_argument('-f', '--files', default='*.po')
    uw.add_argument('-l', '--language', default='sv')
    uw.add_argument('--method', choices=['translate', 'source', 'suggest', 'approve'], default='translate')
    dp = subs.add_parser('deepl')
    dp.add_argument('--deepl-key', default=os.environ.get('DEEPL_AUTH_KEY'))
    dp.add_argument('-g', '--glossary')
    dp.add_argument('-p', '--project', required=True)
    dp.add_argument('-c', '--component', default='*')
    dp.add_argument('-l', '--language', default='sv')
    gl= subs.add_parser('glossary')
    gl.add_argument('-p', '--project',)
    gl.add_argument('-l', '--language', default='sv') 
    gl.add_argument('-t', '--file_type',choices=['tbx', 'csv'],
        help='Select file type: "tbx" or "csv".')
    
    args = parser.parse_args()

    # Setup URL och token
    if args.weblate:
        if args.weblate == 'odoo':
            url = "https://translate.odoo.com/api/"
            token = os.environ.get('ODOO_API_KEY')
            glossary_project='odoo-glossaries'
            glossary_component='odoo-main-glossary'
        elif args.weblate == 'oca':
            url = "https://translation.odoo-community.org/api/"
            token = os.environ.get('OCA_API_KEY')
            glossary_project=args.project
            glossary_component=f'{glossary_project}.glossary'
        else:
            url = args.url
            token = args.token
        if not token:
            print(f"Error: environment variable for {args.weblate} token is not set.")
            return 1
    else:
        url = args.url
        token = args.token

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    if not args.command:
        parser.print_help()
        return 1

    client = WeblateWLCClient(url, token)

    # Kör valt kommando
    try:
        if args.command == 'list-projects':
            print("\n".join(client.list_all_project_slugs()))

        elif args.command == 'list-components':
            print("\n".join(client.list_component_slugs(args.project)))

        elif args.command == 'list-translations':
            for tr in client.list_translations(args.project, args.component).get('results', []):
                print(f"{tr['language']['code']}: {tr['language']['name']} ({tr['translated_percent']:.1f}%)")

        elif args.command == 'download':
            out = args.output or f"{args.project}-{args.component}-{args.language}.po"
            client.download_po_file(args.project, args.component, args.language, out)

        elif args.command == 'upload':
            client.upload_po_file(args.project, args.component, args.language, args.file, args.method)

        elif args.command == 'download-multi':
            client.download_components_wildcard(args.project, args.component, args.language, args.output_dir)

        elif args.command == 'glossary':
            client.download_glossary(glossary_project, glossary_component,args.language, args.file_type)

        elif args.command == 'upload-multi':
            client.upload_files_wildcard(args.files, args.language, args.method)

        elif args.command == 'deepl':
            if not args.deepl_key:
                logger.error("DeepL key required (set --deepl-key or DEEPL_AUTH_KEY env var)")
                return 1
            deepl_command(client, args.deepl_key, args.project, args.component, args.language, args.glossary)

    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
