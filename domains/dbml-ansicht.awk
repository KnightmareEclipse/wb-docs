# Fügt die je Domäne gepflegten DBML-Dateien zu einer ladbaren Gesamtansicht
# zusammen und wirft auf Wunsch die reinen Wertelisten heraus.
#
# Aufruf (steht auch im Kopf beider Quelldateien) — Stammdaten IMMER zuerst,
# sie trägt den Project-Block und die Tabellen, auf die der Putzdienst zeigt:
#
#   awk -v lookups=1 -f domains/dbml-ansicht.awk \
#       domains/stammdaten-schema.dbml domains/putzdienst-schema.dbml \
#       > domains/schema-gesamt.dbml
#
#   awk -f domains/dbml-ansicht.awk \
#       domains/stammdaten-schema.dbml domains/putzdienst-schema.dbml \
#       > domains/schema-gesamt-ohne-lookups.dbml
#
# Warum die Ansicht ohne Wertelisten: countries allein hängt an vier Spalten
# (Anschrift, Geburtsland, Staatsangehörigkeit, zweite Staatsangehörigkeit).
# Neun solcher Tabellen überlagern im Diagramm genau die Kanten, auf die es
# beim Prüfen der Beziehungen ankommt.
#
# Entfernt werden die Tabellen selbst UND die Ref:-Zeilen, die auf sie zeigen —
# ein Ref auf eine fehlende Tabelle lässt dbdiagram.io die Datei abweisen. Die
# verweisenden Spalten (persons.gender_id und so weiter) BLEIBEN stehen: dass
# es sie gibt, gehört zur Struktur, nur ihr Ziel ist hier uninteressant.
#
# Schulzweig, Klassenstufe und Klasse gelten bewusst NICHT als Werteliste,
# obwohl sie in der .sql im selben Block stehen: sie tragen echte Beziehungen
# samt dem zusammengesetzten Fremdschlüssel classes → grade_levels, und genau
# der ist beim Prüfen interessant. cleaning_reminder_stages ebenso wenig — das
# ist Konfiguration je Zyklus, kein Wertevorrat.
#
# Kommentarzeilen der Quellen fallen weg: die Prosa gehört dorthin, hier zählt
# das Diagramm. Die Note:-Texte in den Tabellen bleiben, dbdiagram zeigt sie am
# Kasten an.

BEGIN {
    split("genders salutations guardian_categories denominations " \
          "languages countries phone_types previous_schools " \
          "cleaning_duty_types", lookup, " ")
    if (!lookups) for (i in lookup) drop[lookup[i]] = 1

    print "// ABGELEITET aus stammdaten-schema.dbml + putzdienst-schema.dbml — nie von Hand pflegen."
    print "// Regenerieren: siehe Kopf von domains/dbml-ansicht.awk."
    if (lookups)
        print "// Vollständige Ansicht: alle Tabellen beider gebauten Domänen."
    else
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

# Kommentare der Quellen verwerfen
/^[[:space:]]*\/\// { next }

# Mehrfache Leerzeilen zusammenfassen, die durch das Entfernen entstehen
/^[[:space:]]*$/ { if (blank) next; blank = 1; print ""; next }

{ blank = 0; print }
