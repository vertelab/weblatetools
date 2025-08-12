## make it executable!
## chmod +x deepltrans.py

import polib
import deepl
import getopt
import sys

DEEPL_API_TOKEN = "DEEPL_API_TOKEN"
## Get your own token to insert at https://www.deepl.com/

global argv
global opts
global args

argv = sys.argv[1:]
opts, args = getopt.getopt(argv, "f:l:")

def translate(text, lang):
    translator = deepl.Translator(DEEPL_API_TOKEN)
    return str(translator.translate_text(text, target_lang=lang))

def get_filename():
    # read arguments from command line
    for opt, arg in opts:
        if opt in ['-f']:
            filename = arg
    if not filename:
            print('Please enter the filename of the PO file e.g. /directory/django.po:')
            filename = input()
    return filename

def get_target_language():
    # read arguments from command line
    for opt, arg in opts:
        if opt in ['-l']:
            lang = arg
    if not lang:
            print('Please enter two letter ISO language code e.g. DE:')
            lang = input()
    return lang

def process_file(filename, lang):
    po = polib.pofile(filename)
    for entry in po.untranslated_entries():
        if not entry.msgstr:
            print(entry.msgid)
            print('translating...')
            trans = translate(entry.msgid, lang)
            ## 2024-10-14 LEAVE OUT COMMON ERRORS FROM TRANSLATION. BETTER NO TRANSLATION THAN BAD AND ERROR BASED TRANSLATION!
            ## 2024-11-08 USE $dennis-cmd lint TO SELECT THE WRONG AND ERRORS! 
            #if "</tabell>" in trans or "<span> </span" in trans or "</strong> </strong" in trans or "</div> </div>" in trans:
            #	continue
            entry.msgstr = trans
            print(entry.msgstr)
            print('\n')
        po.save(filename)

if __name__ == '__main__':
    process_file(get_filename(), get_target_language())
