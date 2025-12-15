#!/usr/bin/env python3
import subprocess
import os
import shutil
import tempfile
import glob

def get_odoo_version():
    result = subprocess.run(["odoo", "--version"], capture_output=True, text=True, check=True)
    for part in result.stdout.split():
        if part.split('.')[0].isdigit():
            return part.split('.')[0]
    raise RuntimeError("Kunde inte hitta Odoo-version")

def parse_po_filename(filename):
    base = os.path.basename(filename)
    parts = base.split('-')
    if len(parts) < 4:
        raise ValueError(f"Felaktigt filnamn: {filename}")
    version = parts[1]
    module = parts[2]
    lang = parts[3].split('.')[0]
    return version, module, lang

def get_local_po_path(module, lang="sv"):
    base_dir = "/usr/share/core-odoo/addons"
    return os.path.join(base_dir, module, "i18n", f"{lang}.po")

def find_matching_po_files(repo_dir, odoo_version, lang="sv"):
    pattern = os.path.join(repo_dir, f"odoo-{odoo_version}-*-{lang}.po")
    return glob.glob(pattern)

def get_file_stats(file_path):
    size_kb = os.path.getsize(file_path) / 1024
    lines = sum(1 for _ in open(file_path))
    return round(size_kb, 1), lines


def process_module(github_po_path, module_name):
    odoo_version = get_odoo_version()

    # Rensa hela /usr/share/odoosa-translate/ först
    base_work_dir = "/usr/share/odoosa-translate"
    if os.path.exists(base_work_dir):
        try:
            shutil.rmtree(base_work_dir)
            print(f"🧹 Rensade {base_work_dir}")
        except PermissionError:
            subprocess.run(['sudo', 'rm', '-rf', base_work_dir], check=True)
            print(f"🧹 Rensade {base_work_dir} med sudo")

    # Skapa fräsch arbetskatalog
    try:
        os.makedirs(base_work_dir, exist_ok=True)
    except PermissionError:
        subprocess.run(['sudo', 'mkdir', '-p', base_work_dir], check=True)
        subprocess.run(['sudo', 'chown', f'{os.getuid()}:{os.getgid()}', base_work_dir], check=True)
        print(f"✅ Skapade och ägde {base_work_dir}")

    # STEG 1: Kopiera BARA odoo-18 filen till platt katalog
    github_copy = f"{base_work_dir}/odoo-{odoo_version}-{module_name}-sv.po"
    shutil.copy(github_po_path, github_copy)

    # STEG 2: Kopiera till Odoo core-modul
    odoo_module_path = get_local_po_path(module_name)
    os.makedirs(os.path.dirname(odoo_module_path), exist_ok=True)
    subprocess.run(["sudo", "cp", github_copy, odoo_module_path], check=True)

    # STEG 3: Kör checkmodule från /usr/share/odoosa-translate/
    cmd = ["checkmodule", "-d", "jakob_translate", "-m", module_name, "-e", "-l", "info", "--drop"]
    result = subprocess.run(cmd, cwd=base_work_dir, capture_output=True, text=True)

    if result.returncode != 0:
        print(f"✗ {module_name}: checkmodule misslyckades!")
        print(f"  Fel: {result.stderr}")
        return

    # STEG 4: Hitta exporterad fil (namnet är modulnamn.po)
    exported_po_pattern = f"{base_work_dir}/{module_name}.po"
    if not os.path.exists(exported_po_pattern):
        print(f"✗ {module_name}: Ingen {module_name}.po exporterades!")
        return

    exported_po = exported_po_pattern

    # STEG 5: Jämför med GitHub-kopian
    github_size, github_lines = get_file_stats(github_copy)
    exported_size, exported_lines = get_file_stats(exported_po)
    line_diff = abs(github_lines - exported_lines)

    if line_diff <= 4:
        print(f"✓ {module_name}: OK (skillnad {line_diff} rader)")
        os.unlink(github_copy)
        os.unlink(exported_po)
        return

    # STEG 6: BEHÖVER ÖVERSÄTTAS!
    print(f"⚠ {module_name}: ÄNDRINGAR DETEKTERADE!")
    print(f"  GitHub: {github_size}KB, {github_lines} rader")
    print(f"  Exporterad: {exported_size}KB, {exported_lines} rader")
    print(f"  Skillnad: {line_diff} rader")

    # LÅT BÅDA FILERNA LIGGA KVAR FÖR MANUELL GRANSKNING
    shutil.copy(exported_po, f"/tmp/to_translate-{module_name}-sv.po")
    print(f"  → Kolla: {github_copy} och {exported_po}")

def main():
    odoo_version = get_odoo_version()
    print(f"Odoo version: {odoo_version}")

    with tempfile.TemporaryDirectory() as tmpdir:
        print(f"Klona repo till: {tmpdir}")
        subprocess.run(['git', 'clone', 'https://github.com/vertelab/odoosa-translate.git', tmpdir], check=True)

        # DEBUG: Visa vad som finns
        all_po = glob.glob(os.path.join(tmpdir, "*.po"))
        print(f"Hittade {len(all_po)} .po-filer totalt")
        for f in all_po[:3]:  # Första 3
            print(f"  - {os.path.basename(f)}")

        po_files = find_matching_po_files(tmpdir, odoo_version)
        print(f"Hittade {len(po_files)} odoo-{odoo_version}-*-sv.po filer")

        if not po_files:
            print("❌ Inga matchande .po-filer för din Odoo-version!")
            return

        for po_file in po_files:
            print(f"\n🔄 Bearbetar: {os.path.basename(po_file)}")
            _, module_name, _ = parse_po_filename(po_file)
            process_module(po_file, module_name)

if __name__ == "__main__":
    main()
