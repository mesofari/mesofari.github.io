# Kai Music Lounge – Community-Levelsystem (Entwicklungsstand)

## Bereits im Entwurfsbranch enthalten
- `music/index.html`: öffentlich sichtbare Rangliste, persönliches Level, XP-Balken, Registrierung/Anmeldung über Supabase Auth, sobald konfiguriert.
- `music/supabase-setup.sql`: Datenbankschema für Mitglieder, Themenabende, Einreichungen, XP-Einträge und N26-Zahlungsnachweise.
- Link von der Hauptseite zur Level-Seite.

**Nicht live / nicht vollständig:** Supabase-Projekt noch nicht angelegt, URL und publishable/anon key sind Platzhalter; keine echten Songs oder Zahlungen sind angebunden. Das SQL ist eine Startmigration für eine frische Datenbank und benötigt Sicherheits-/Integrationstests. Das Admin-Dashboard für Einreichungsfreigaben, Eventverwaltung und Zahlungsprüfung fehlt noch.

## XP-Regeln
- Level 1 bis 50.
- Schwellen: Level 2–5 jeweils +10 XP; anschließend erhöht sich der nächste benötigte XP-Schritt um 5 XP je Level.
- Erster durch den Admin freigegebener Song pro Mitglied und Event: +10 XP (nicht schon beim Absenden). Einzigartigkeit wird durch `unique(event_id,user_id)` erzwungen.
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

## Öffentliche Community-Mitglieder (Erweiterung 17.11.2026)
- Über `music/` erscheint die öffentliche Community-Mitgliederliste mit Level und XP.
- Bei kostenloser Registrierung wird automatisch ein Profil mit zufälligem Nickname angelegt; ein frei gewählter Name lässt sich nach der Anmeldung über die gesicherte RPC ändern.
- Alle Besucher können die sichtbaren Nicknames, Level und XP sehen; nicht aber E-Mail-Adressen, Bankdaten, Songgeschichten oder Zahlungsbuchungen.
- Die Community-Mitgliederseite zeigt zunächst 30 Profile und lädt über „Weitere Mitglieder anzeigen“ alle weiteren seitenweise. Die Daten kommen aus einer besonders eingeschränkten RPC ohne interne Benutzer-IDs.
- Für dauerhafte XP-Zuordnung ist ein Benutzerkonto nötig. Ohne Anmeldung sind keine anonymen XP-Ansprüche verifizierbar.
- Einreichungen werden aktuell ausschließlich in der Datenbank vorbereitet; eine echte öffentliche Einreichungsoberfläche und die Freigabeoberfläche müssen noch gebaut werden.
- Eigene Lösch-/Exportfunktionen, Anti-Spam, Datenschutz-Test, Löschfristen und Dienstleisterangaben müssen vor Livegang fertig sein.

## Rechtliche Entwürfe
- `music/datenschutz.html` (DSGVO-Informationsentwurf)
- `music/teilnahmebedingungen.html` (Teilnahme- und Fairplaybedingungen)
- `music/community-melden.html` (Kontakt für problematische Inhalte)
- Bestehendes `../impressum.html` bleibt erhalten.
**Keine anwaltliche Prüfung, keine Behauptung vollständiger Compliance.** Tatsächliche Supabase-Region/Unterauftragnehmer, Aufbewahrungszeiten, Berechtigung des Musikstreamings und Moderationsprozesse vor Aktivierung verifizieren.

## Rechtliche Quellen und Prüfbedarf (Stand November 2026)
- § 5 DDG: https://www.gesetze-im-internet.de/ddg/__5.html
- Art. 13 DSGVO: https://eur-lex.europa.eu/eli/reg/2016/679/oj
- Bundesnetzagentur DSA-Pflichten (Einordnung je nach Dienst erforderlich): https://www.bundesnetzagentur.de/DE/Fachthemen/DSC/1_Themen/PflichtenVermittlunggsdienste/start.html
- Musikrechte im Social Media-Stream: https://www.gema.de/de/hilfe/musiknutzer/musik-nutzen/social-media-websites
- EU-ODR-Plattform geschlossen seit Juli 2025: https://consumer-redress.ec.europa.eu/site-relocation_en
