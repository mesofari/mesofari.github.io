# Kai Music Lounge – Aktueller Seitenaufbau

Stand: 17. November 2026

## Besucherführung
- `/music/`: freundlicher Willkommensbildschirm mit Dank, Musik-Community-Erklärung, Überblick, neuen Events und den zentralen Buttons.
- `/music/community.html`: kostenlose Registrierung und Anmeldung, bestehende Profile, permanente Kai’s Community-Mitgliedsbanner, Levels und öffentliche Mitgliederliste; Namen können später geändert werden.
- `/music/events.html`: Themenabende, Songlinks mit persönlicher Geschichte, öffentliche faire Warteschlange.
- `/music/unterstuetzen.html`: freiwillige Community-Unterstützung mit exakt neun Beträgen (1/2/5/10/20/50/100/500/1000 €), N26-Empfänger, kopierbarer IBAN und EPC-SEPA-GiroCode.
- `/music/admin.html`: geschütztes Dashboard für Veranstaltungen, Moderation und manuelle Bankbestätigungen.
- Datenschutz, Teilnahmebedingungen, Meldeseite und vorhandenes MESOFARI-Impressum bleiben verlinkt.

## Persönlicher Zahlungscode
Nach Anmeldung generiert die Unterstützungsseite den Verwendungszweck `KML-<user UUID>`, der im GiroCode und bei Kopieren enthalten ist. Bei Gästen ist nur eine nicht zuordenbare allgemeine Unterstützung möglich. Das ist kein Online-Zahlungsabschluss: die Überweisung erfolgt in der eigenen Banking-App; die Website besitzt keinen Kontozugriff und bestätigt keinen Zahlungseingang. XP werden ausschließlich nach Verifizierung im geschützten Adminbereich vergeben. 1 € = 1 XP. Die auswählbaren Beträge haben keine Centvarianten.

## Grundregeln
Alle Songplätze sind kostenlos; keine bezahlte Priorisierung. +10 XP für den ersten freigegebenen Song eines Mitglieds je Event. Level 1–50, danach XP weiter zählen. Private Songgeschichten, Bankvorgänge und E-Mail-Adressen bleiben nichtöffentlich.

## Technische Infrastruktur
GitHub Pages mit der bisherigen Domain `mesofari.de`, Supabase-Free-Projekt `kai-music-lounge` (Projektkennung `qqykuvzketipuvpzujms`). Browser verwendet ausschließlich den öffentlichen Publishable Key, niemals den Service-Role-Key. Community-Profile und Admin-Rechte bestehen weiter.

## Noch zu prüfen
End-to-End-Test auf Mobilgeräten: Registrierung, Passwort/E-Mail-Bestätigung, Namensänderung, Veranstaltungsverwaltung, Einreichungsfreigabe und die Warteschlange. EPC-QR mit konkreter Banking-App vor echten Zahlungen testen, alternativ Copy-Funktionen verwenden. Datenschutztexte und Löschfristen anhand tatsächlich eingesetzter Dienste rechtlich finalisieren. Bei größeren Nutzerzahlen Spam-Schutz und Moderation ergänzen. Github-Auslieferung und Cache invalidation kann leicht verzögert sein.

## UX-Anforderungen
Der Willkommensbereich soll warm, inklusiv und dankbar sein: „Musik verbindet“ und jeder Besucher ist ohne Geldbeitrag willkommen. Bezahlfunktionen nur auf der Unterstützungsseite. Profile zeigen dauerhaft das Community-Banner mit Namen/XP, aber keine Bankangaben. Alle Wege bleiben mobil gut erreichbar.

## Automatische Mitgliedschaft (November 2026)
Beim ersten Einreichen per `music/events.html` verwendet der Browser `supabase.auth.signInAnonymously({options:{data:{community_name}}})`. Der bestehende Supabase-Trigger `lounge_private.new_profile` legt ein eindeutiges öffentliches Profil an. Der Song wird dann immer mit `user_id` angelegt; `lounge_private.credit_song` schreibt nach Admin-Freigabe genau einmal 10 XP gut. Die Browser-Sitzung dient als Eigentumsnachweis und geht bei Cookie-/Browserdaten-Löschung verloren. In `music/community.html` gibt es eine freiwillige E-Mail-Verifikation zur dauerhaften Sicherung. Erforderliche Betriebs-Einstellung: **Supabase Authentication → Sign In / Providers → Allow anonymous sign-ins einschalten**. Ohne diese Umschaltung funktioniert die automatische Erst-Einreichung noch nicht. Öffentliche anonyme Datenbank-INSERTs sind wieder gesperrt; andernfalls wären XP ohne Identität übernehmbar.
