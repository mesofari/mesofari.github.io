# Kai Music Lounge – Community-Levelsystem (Entwicklungsstand)

## Bereits im Entwurfsbranch enthalten
- `music/index.html`: öffentlich sichtbare Rangliste, persönliches Level, XP-Balken, Registrierung/Anmeldung über Supabase Auth, sobald konfiguriert.
- `music/supabase-setup.sql`: Datenbankschema für Mitglieder, Themenabende, Einreichungen, XP-Einträge und N26-Zahlungsnachweise.
- Link von der Hauptseite zur Level-Seite.

**Nicht live / nicht vollständig:** Supabase-Projekt noch nicht angelegt, URL und publishable/anon key sind Platzhalter; keine echten Songs oder Zahlungen sind angebunden. Das SQL ist eine Startmigration für eine frische Datenbank und benötigt Sicherheits-/Integrationstests. Das Admin-Dashboard für Einreichungsfreigaben, Eventverwaltung und Zahlungsprüfung fehlt noch.

## XP-Regeln
- Level 1 bis 50.
- Schwellen: Level 2–5 jeweils +10 XP; anschließend erhöht sich der nächste benötigte XP-Schritt um 5 XP je Level.
- Erste gültige Song-Einreichung pro Mitglied und Event: +10 XP. Einzigartigkeit wird durch `unique(event_id,user_id)` erzwungen.
- Unterstützung: 1 € = 1 XP. Gespeichert werden Cent; bei nicht vollen Euro wird für XP abgerundet. 1,99 € => 1 XP; 10 € => 10 XP; 1000 € => 1000 XP.
- Level 50 ist die Grenze; XP darüber zählen weiter.
- Öffentliche Ansicht: Community-Namen, XP, Level. Keine Kontodaten, Zahlungshistorie, E-Mail oder Songgeschichte.

## Warum N26-Überweisung nicht automatisch XP gibt
Eine normale SEPA-Überweisung an die N26-IBAN liefert kein vertrauenswürdiges Ereignis an GitHub Pages.
1. Mitglied registriert sich, sieht seinen eindeutigen Verwendungszweck (KML-<User-ID>).
2. Mitglied überweist freiwillig an das bekannte Geschäftskonto.
3. Kontoinhaber überprüft **wirklich eingegangenes Geld** im N26-Konto und gleicht Betrag/Verwendungszweck ab.
4. Nur ein sicherer Server-/Admin-Prozess mit Service-Rolle darf `lounge_confirm_support` einmalig aufrufen. Die Funktion verweigert öffentliche Aufrufe; der eindeutige Bank-Transaktionsbezug verhindert Doppelbuchungen.
5. Danach werden XP und das Level beim Neuladen aktualisiert; erst dann darf eine Erfolgsmeldung „Vielen Dank – deine Unterstützung wurde bestätigt“ erscheinen.

**Niemals** eine geheime Supabase-Service-Role in HTML/JavaScript oder auf GitHub ablegen. Niemals XP allein aufgrund eines Browser-Klicks erteilen.

## Vor dem Livegang
1. Supabase-Projekt erstellen und SQL in einer frischen Testdatenbank prüfen.
2. Supabase Auth URL-Konfiguration und E-Mail-Verifikation festlegen.
3. Supabase-Projekt-URL und **nur öffentlichen** publishable/anon key in `music/index.html` einsetzen.
4. Verwaltungsfunktionen für Events, Songfreigaben und Zahlungseingang mit starkem Admin-Schutz implementieren. Als weitere Stufe: Rate Limiting, CAPTCHA, Anti-Spam, Moderation.
5. Prüfung der Datenbank-RLS-Regeln mit Testkonten (öffentlich, fremdes Mitglied, eigenes Mitglied, Admin) und SEPA-Doppelbuchungen.
6. Datenschutztext mit Accounts, öffentlich sichtbaren Namen/XP sowie Bank-/Support-Prozessen aktualisieren. Überprüfung des rechtlichen Rahmens für freiwillige Unterstützungen.
7. Entwurfs-PR prüfen und erst nach erfolgreichem Test zusammenführen.

## Fairness
XP verschafft **keinen Vorrang** in der Songliste. Die Reihenfolge bleibt zeitlich aufsteigend nach Song-Einreichung. Ein Level ist ein öffentliches Anerkennungsabzeichen, kein käuflicher Vorteil.
