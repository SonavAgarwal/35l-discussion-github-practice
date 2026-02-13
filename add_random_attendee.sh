#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_FILE="${ROOT_DIR}/attendees.json"

if [[ ! -f "${JSON_FILE}" ]]; then
  echo "attendees.json not found at ${JSON_FILE}" >&2
  exit 1
fi

new_name="$(
  python3 - <<'PY' "${JSON_FILE}"
import json
import random
import sys

json_path = sys.argv[1]

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

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)
        f.write("\n")

data = load_json(json_path)
if not isinstance(data, list):
    raise SystemExit("attendees.json must be a JSON array.")

name = f"{random.choice(first_names)} {random.choice(last_names)}"
entry = {
    "name": name,
    "image": "",
    "link": "https://www.linkedin.com/"
}

insert_at = random.randint(0, len(data))
data.insert(insert_at, entry)
save_json(json_path, data)

print(name)
PY
)"

git add "${JSON_FILE}"
git commit -m "Add attendee: ${new_name}"

echo "Added ${new_name}"
