#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_FILE="${ROOT_DIR}/data.js"

if [[ ! -f "${DATA_FILE}" ]]; then
  echo "data.js not found at ${DATA_FILE}" >&2
  exit 1
fi

new_name="$(
  python3 - <<'PY' "${DATA_FILE}"
import json
import random
import sys
import re

data_path = sys.argv[1]

first_names = [
    "Alex","Avery","Blake","Casey","Drew","Elliot","Emerson","Hayden","Jamie",
    "Jordan","Kai","Logan","Morgan","Parker","Quinn","Riley","Rowan","Sawyer",
    "Skyler","Taylor","Zion","Reese","Jules","Harper","Noel","Sage","Ari","Remy",
    "Addison","Adrian","Aisha","Akira","Alana","Alina","Amari","Amaya","Amelia",
    "Amir","Anika","Aria","Asher","Aubrey","Avery","Beau","Bianca","Bodhi",
    "Brooke","Caleb","Camila","Cara","Carmen","Cedar","Chase","Clara","Cleo",
    "Cody","Cole","Cora","Dahlia","Damian","Daphne","Darius","Declan","Delia",
    "Derek","Dylan","Elena","Elise","Eliza","Ellie","Emil","Enzo","Esme","Ezra",
    "Fiona","Freya","Gabe","Gemma","Gideon","Giselle","Hana","Harris","Helena",
    "Hugo","Imani","Iris","Ivan","Jade","Jalen","Jasper","Jenna","Joanna","Juno",
    "Kaia","Kara","Kendall","Kieran","Kiki","Kira","Laila","Lana","Leah","Leona",
    "Liam","Lila","Lina","Luca","Luna","Lyra","Mabel","Malia","Maren","Maya",
    "Miles","Mila","Mina","Mira","Nadia","Naomi","Nico","Nina","Noah","Nora",
    "Omar","Orion","Owen","Paige","Pia","Quentin","Rafael","Raina","Reid","Rhea",
    "Ronan","Rosa","Ruby","Sabrina","Sage","Sam","Selah","Sienna","Silas","Sloane",
    "Sonia","Stella","Theo","Tobias","Uma","Vera","Violet","Wes","Willow","Xena",
    "Yara","Zara","Zeke"
]

last_names = [
    "Adams","Baker","Carter","Davis","Ellis","Foster","Garcia","Hayes","Irwin",
    "Jenkins","Klein","Lopez","Morris","Nguyen","Owens","Patel","Quincy",
    "Reed","Singh","Turner","Usman","Vargas","Walker","Xu","Young","Zhang",
    "Abbott","Alvarez","Anderson","Archer","Atkins","Bennett","Bowen","Bradley",
    "Brooks","Burke","Callahan","Campbell","Carlson","Chan","Clarke","Coleman",
    "Collins","Cruz","Daniels","Dawson","Diaz","Donovan","Doyle","Duncan",
    "Edwards","Farrell","Fischer","Fleming","Gaines","Gallagher","Garner",
    "Gibson","Gordon","Griffin","Hale","Hammond","Han","Hendrix","Holland",
    "Holmes","Hughes","Ibrahim","Ingram","James","Kane","Kim","Knight","Larsen",
    "Lawson","Lee","Levy","Liu","Long","Marshall","Martin","Mendoza","Mills",
    "Mitchell","Montgomery","Moore","Murray","Nash","Navarro","Nelson","Norton",
    "Obrien","Ortiz","Parker","Pearson","Peters","Price","Quinn","Ramirez",
    "Reynolds","Rios","Rogers","Romero","Russell","Salazar","Sanchez","Sanders",
    "Schmidt","Shah","Simmons","Spencer","Stevens","Stone","Sullivan","Sutton",
    "Taylor","Thompson","Vaughn","Walsh","Ward","Watson","Wong","Wright","Yu"
]

with open(data_path, "r", encoding="utf-8") as f:
    script = f.read()

# Fix any accidentally escaped newlines in markers from prior runs.
script = script.replace("// <STARTDATA>\\n", "// <STARTDATA>\n")
script = script.replace("\\n// <ENDDATA>", "\n// <ENDDATA>")

start_marker = "// <STARTDATA>"
end_marker = "// <ENDDATA>"
start_idx = script.find(start_marker)
end_idx = script.find(end_marker)
if start_idx == -1 or end_idx == -1 or end_idx <= start_idx:
    raise SystemExit("Could not find <STARTDATA> / <ENDDATA> block in data.js.")

block = script[start_idx:end_idx]
array_start = block.find("[")
array_end = block.rfind("]")
if array_start == -1 or array_end == -1 or array_end <= array_start:
    raise SystemExit("Could not find attendeeData array inside markers.")

array_text = block[array_start:array_end + 1]
data = json.loads(array_text)
if not isinstance(data, list):
    raise SystemExit("data.js attendeeData must be a JSON array.")

name = f"{random.choice(first_names)} {random.choice(last_names)}"
entry = {
    "name": name,
    "image": "",
    "link": "https://www.linkedin.com/"
}

insert_at = random.randint(0, len(data))
data.insert(insert_at, entry)

json_str = json.dumps(data, ensure_ascii=False, indent=4)

line_start = script.rfind("\\n", 0, start_idx) + 1
indent = script[line_start:start_idx]
indented_json = json_str.replace("\\n", "\\n" + indent)

replacement_block = (
    f"{start_marker}\n"
    f"{indent}var attendeeData = {indented_json};\n"
    f"{end_marker}"
)

script = script[:start_idx] + replacement_block + script[end_idx + len(end_marker):]

with open(data_path, "w", encoding="utf-8") as f:
    f.write(script)

print(name)
PY
)"

git add "${DATA_FILE}"
git commit -m "Add attendee: ${new_name}"

echo "Added ${new_name}"
