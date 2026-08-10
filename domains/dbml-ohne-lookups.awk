# Erzeugt stammdaten-schema-ohne-lookups.dbml aus stammdaten-schema.dbml:
# dieselbe Struktur ohne die reinen Wertelisten, damit im Diagramm die
# Beziehungen zwischen den Entitäten sichtbar bleiben. countries allein hängt an
# vier Spalten (Anschrift, Geburtsland, Staatsangehörigkeit, zweite
# Staatsangehörigkeit) — acht solcher Tabellen überlagern die Kanten, auf die es
# beim Prüfen ankommt.
#
# Aufruf (Regenerier-Befehl steht auch im Kopf der Quelldatei):
#   awk -f domains/dbml-ohne-lookups.awk domains/stammdaten-schema.dbml \
#       > domains/stammdaten-schema-ohne-lookups.dbml
#
# Entfernt werden die Tabellen selbst UND die Ref:-Zeilen, die auf sie zeigen —
# ein Ref auf eine fehlende Tabelle lässt dbdiagram.io die Datei abweisen. Die
# verweisenden Spalten (persons.gender_id und so weiter) BLEIBEN stehen: dass es
# sie gibt, gehört zur Struktur, nur ihr Ziel ist hier uninteressant.
#
# Schulzweig, Klassenstufe und Klasse gelten bewusst NICHT als Werteliste,
# obwohl sie in der .sql im selben Block stehen: sie tragen echte Beziehungen
# samt dem zusammengesetzten Fremdschlüssel classes → grade_levels, und genau
# der ist beim Prüfen der Beziehungen interessant.
#
# Kommentarzeilen der Quelle fallen weg — die Prosa gehört in die Quelldatei,
# hier zählt das Diagramm. Die Note:-Texte in den Tabellen bleiben, dbdiagram
# zeigt sie am Kasten an.

BEGIN {
    split("genders salutations guardian_categories denominations " \
          "languages countries phone_types previous_schools", lookup, " ")
    for (i in lookup) drop[lookup[i]] = 1

    print "// ABGELEITET aus stammdaten-schema.dbml — nie von Hand pflegen."
    print "// Regenerieren: awk -f domains/dbml-ohne-lookups.awk domains/stammdaten-schema.dbml > " \
          "domains/stammdaten-schema-ohne-lookups.dbml"
    print "// Reine Wertelisten und ihre Ref:-Zeilen sind entfernt; die verweisenden Spalten bleiben."
    print ""
    blank = 1
}

# Tabellenblock einer Werteliste überspringen
/^Table / { skip = ($2 in drop) }
skip      { if ($0 ~ /^\}/) skip = 0; next }

# Ref:-Zeile fällt weg, sobald eine der beiden Seiten eine Werteliste ist.
# Trennzeichen so gewählt, dass "persons.gender_id" in "persons" und
# "gender_id" zerfällt und auch die zusammengesetzte Form
# "classes.(grade_level_id, school_branch_id)" sauber zerlegt wird.
/^Ref:/ {
    n = split($0, tok, /[ ,>()\[\].-]+/)
    for (i = 1; i <= n; i++) if (tok[i] in drop) next
}

# Kommentare der Quelle verwerfen
/^[[:space:]]*\/\// { next }

# Mehrfache Leerzeilen zusammenfassen, die durch das Entfernen entstehen
/^[[:space:]]*$/ { if (blank) next; blank = 1; print ""; next }

{ blank = 0; print }
