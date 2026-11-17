# Kai Music Lounge – technische Übergabe (17. November 2026)

## Plattform
- Bestehende MESOFARI-Site auf GitHub Pages, keine neue Domain notwendig.
- URL nach Zusammenführung: https://mesofari.de/music/
- Supabase-Free-Projekt: `kai-music-lounge` (EU-Irland, Projektreferenz `qqykuvzketipuvpzujms`).
- Die im Browser verwendete Konfiguration ist ausschließlich der **öffentliche** publishable Key: `music/config.js`. Keine geheime Service-Role in GitHub.

## In diesem Entwicklungszweig umgesetzt
- `index.html`: MESOFARI-Einstieg Apps / Spiele / Music Lounge und freiwillige Community-Unterstützung per N26-Überweisung (Beträge 1,2,5,10,20,50,100,500,1000 Euro).
- `music/index.html`: Mitgliederregistrierung, Anmeldung, öffentlicher Level-/XP-Verlauf, persönliche Community-ID und Mitgliederliste (paginiert).
- `music/events.html`: öffentliche Themenabende, Songlink + Geschichte, Zustimmung zu Regeln, öffentliche Warteschlange (30 Sekunden Auto-Refresh).
- `music/admin.html`: abgesicherte Admin-Oberfläche für Events, Freigaben, Moderation und manuelle Bestätigung realer N26-Eingänge.
- `music/lounge.css`: responsives Dark/Gold/Violett-Design.
- Eigene `music/datenschutz.html`, `music/teilnahmebedingungen.html`, `music/community-melden.html`; bestehendes MESOFARI-Impressum verlinkt.

## In Supabase angelegt
- Tabellen: `public.lounge_profiles`, `public.lounge_events`, `public.lounge_songs`.
- Streng private Tabellen: `lounge_private.admin_users`, `lounge_private.supports`, `lounge_private.xp_ledger`.
- Trigger schützen Einreichungsgrenzen und vergeben einmalig **10 XP** nach administrativer Freigabe.
- Nur die neun festgelegten ganzzahligen Eurobeträge können im Admin-Bereich manuell nach bestätigtem Zahlungseingang gutgeschrieben werden (**1 Euro = 1 XP**). Unique Bankreferenz verhindert doppelte Buchung.
- Öffentliche APIs erlauben nur Namen, Level/XP und die freigegebene Warteschlange. Geschichten bleiben intern.
- Die Level 1-50 brauchen kumulativ 0 bis 5665 XP; ab Level 50 zählen XP weiter.
- Datenbank-Migrationen wurden angewendet und Levelschwellen getestet. Die früher geplante Beispiel-DDL in `music/supabase-setup.sql` ist **absichtlich durch einen nur-lesenden Test ersetzt**.

## Vor dem öffentlichen Betrieb noch erforderlich
1. GitHub-PR #1 prüfen und zusammenführen, damit die Seiten tatsächlich unter mesofari.de erscheinen.
2. In Supabase: **Authentication → URL Configuration**: Site URL = `https://mesofari.de`, zusätzliche Redirect-URL = `https://mesofari.de/music/` (ggf. www-Variante, sofern tatsächlich genutzt). Dies ist nicht über die zur Verfügung stehende Supabase-Verbindung konfigurierbar.
3. Betreiber registriert über `/music/#profil` ein eigenes Konto, bestätigt die E-Mail-Adresse.
4. Betreiberkonto muss **einmalig** als Admin in `lounge_private.admin_users` hinterlegt werden. Nicht durch bloße E-Mail-Vermutungen oder öffentliches Formular! Beispiel SQL nach Auth-Registrierung und konkreter Prüfung des Kontos:
   `insert into lounge_private.admin_users(user_id) select id from auth.users where email = '<vom Betreiber verifizierte E-Mail>';`
   Nicht ausführen, bevor Nutzer/Adresse sicher identifiziert sind.
5. End-to-End-Tests mit echten, getrennten Admin- und Standardkonten: Registrierung, Event, Song, 10 XP nur nach Freigabe, RLS-Trennung, Warteschlange und Test der Einmaligkeit manueller Zahlungsbestätigungen **ohne fiktive Echtgeld-Buchungen**.
6. Vor öffentlichen Zahlungen oder breiter Einladung: Datenschutzerklärung/AVV/Unterauftragnehmer für GitHub, Supabase, CDN und N26 prüfen; Löschfristen, Kontoauskunft, Datenexport/-löschung, Moderation und jugendschutzrechtliche Anforderungen verbindlich festlegen; Musikrechte für TikTok-Live prüfen. Eine rechtliche Abnahme ist nicht erfolgt.
7. Die beiden vom Betreiber hochgeladenen Originalembleme noch als komprimierte Bilder einbinden – aktuell sind im Code stilisierte Musik-Symbole.
8. Sicherheit im Betrieb: Supabase-RLS und Auth-Einstellungen sowie GitHub-Pages-Deployment überwachen; Abuse-Rate-Limits/CAPTCHA vor großem öffentlichen Start ergänzen.

## Wichtig
- Die Gratis-Tarife haben Begrenzungen und können bei längerer Inaktivität pausieren.
- Die Überweisung an N26 ist **keine automatisch bestätigte Zahlung**. Das Setzen eines Betrags im Browser löst keine Überweisung aus und vergibt keine XP.
- Song-Freigaben und Bankbuchungen sind nur an echte Administratoren gebunden.
- Die Datenbank besteht bereits; **kein zweites Supabase-Projekt** erstellen.
