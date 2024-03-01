# Entwicklung des Redmine CAS-Plugins

## Lokale Einrichtung zum Debuggen

### EcoSystem einrichten
- Ein EcoSystem lokal mit vagrant aufsetzen (`https://github.com/cloudogu/ecosystem`)
- CAS-Dogu in den Development-Mode bringen
  - `etcdctl set config/_global/stage development`
  - `docker restart cas`

### Ruby und Builder mit rvm installieren
- `https://github.com/rvm/rvm`.
  Derzeit wird die Entwicklung mit Ruby 3.0.6 durchgeführt
  Version wechseln `rvm use 3.0.6` (Das muss in jeder Terminal-Instanz erneut durchgeführt werden sowie ggf. in der IDE)
  - alternativ [`rbenv`](https://github.com/rbenv/rbenv?tab=readme-ov-file#homebrew) als Versionsmanager verwenden

### rubycas-client vorbereiten
- Das ist notwendig, um in einem lokal aufgesetzten Redmine das CAS-Plugin nutzen zu können
- Auschecken des Redmine-Quellcodes
  - `git clone https://github.com/cloudogu/rubycas-client.git`
  - Mit dem Terminal in das Verzeichnis des Plugins wechseln
    - `cd ${path/to/projects}/rubycas-client`
  - Darauf achten, dass mit `rvm use` die richtige ruby-version ausgewählt ist
    - rbenv: `rbenv install --skip-existing 3.0.6 && rbenv local 3.0.6`
  - Das Plugin als Gem bauen
    - `gem build rubycas-client.gemspec`
    - hier kommen Warnungen, die ignoriert werden können
    - Eine Gem-Datei wird abgelegt
  - Das Plugin im System installieren, sodass es beim Bau von Redmine gefunden wird
    - `gem install rubycas-client-2.4.0.gem`

### Plugin zusammentragen

- Das `redmine_cas`-plugin in diesem Repository bauen
  - `cd bundle && ./bundle_plugin.rb`
  - es wird eine Verzeichnisstruktur unter `bundle` erzeugt
    - dieses Verzeichnis muss später nach Redmine kopiert werden

### Redmine-Einrichtung
- Auschecken des Redmine-Quellcodes `git clone https://github.com/redmine/redmine.git`
- Auschecken der aktuell verwendeten Redmine-Dogu-Version (z. B. `git checkout 5.0.5`)
- `config/database.yml` folgende Datei anlegen:
```yml
production:
  adapter: sqlite3
  database: db/redmine.sqlite3
development:
  adapter: sqlite3
  database: db/redmine.sqlite3
test:
  adapter: sqlite3
  database: db/redmine.sqlite3
```
- Als `config/secrets.yml` folgende Datei anlegen:
```yml
production:
  secret_key_base: production_secret_key

development:
  secret_key_base: static_secret_key

test:
  secret_key_base: static_test_secret_key

secret_key_base: global_key_for_all_env
```
- Das gebaute cas-plugin in den `<path-to-redmine>/plugins`-Ordner ablegen
- Mit dem Terminal in das Verzeichnis von Redmine wechseln
- Darauf achten, dass mit `rvm use` die richtige ruby-version ausgewählt ist
  - rbenv: `rbenv install 3.0.6 && rbenv local 3.0.6` scheint zu funktionieren
- `config/database.yaml` und `config/secrets.yml` prüfen
  - es gibt Warnungen während `bundle install` (s. u.), wenn YAML-Dateien fehlen
- Config-YAML-Dateien im Redmine-Repo ins Verzeichnis `config/` kopieren 
- Bundler installieren mit `gem install bundler`
- Dependencies installieren mit `bundle install`
- Datenbankmigration durchführen
  - `RAILS_ENV=development bundle exec rake db:migrate`
- Rails für "Ruby on Rails" installieren
  - `gem install rails -v 6.1`
  - die genaue Version entstammt dem Redmine-Gemfile
- Mit `rails server` kann jetzt Redmine lokal gestartet werden

### Einrichtung für Debugging in der IDE (IntelliJ)
- Das eingerichtete Redmine in der IDE öffnen
- File -> Project Structure -> Modules öffnen
- Ist hier ein Modul erstellt, dieses ggf. durch einen Klick auf das Minus entfernen
- Auf das Plus klicken, dann auf Import Module
- Den Pfad von Redmine auswählen
- Next -> Next -> kurz warten, bis ruby on Rails erkannt wird -> finish
- Bei dem importierten Modul die richtige Ruby-Version auswählen
- Es sollte etwa so aussehen:
![module](figures/getting-started/module.png)
- Es sollten zu diesem Zeitpunkt automatisch Run-Konfigurationen angelegt sein
  - Ist das nicht erfolgt, hat sich IntelliJ falsch initialisiert
  - Die beste Lösung für den Fall ist es, Redmine erneut auszuchecken und wieder bei `Redmine-Einrichtung` zu beginnen
- Die Run-Konfigurationen auswählen und anpassen
  - Richtige ruby-version auswählen
- Es sollte in etwa so aussehen:
![run-config](figures/getting-started/run-configuration.png)
- Konfiguration für lokales EcoSystem einrichten (im redmine-Verzeichnis ausführbar, Ersetzungen nicht vergessen)
  ```bash
  rake redmine_cas:change_setting\[admin_group,<your-admin-group>\]
  rake redmine_cas:change_setting\[redmine_fqdn,localhost:3000\]
  rake redmine_cas:change_setting\[cas_fqdn,192.168.56.2\]
  rake redmine_cas:change_setting\[cas_relative_url,/cas\]
  rake redmine_cas:change_setting\[enabled,1\]
  ```
- darauf achten, dass http://localhost:3000/settings?tab=authentication `Authentifizierung erforderlich` auf `Ja` gesetzt wird
- Jetzt kann über die Run-Konfiguration Redmine gestartet werden, auch im debug-Modus
- Mit Vorsicht zu genießen: Es muss im lokalen Redmine dem "Anmelden"-Link, der Anmelden-Dialog angezeigt werden. Es wird sich (dem Namen nach) mit dem lokalen admin angemeldet, aber ein CAS-Passwort verwendet (evtl. nur wenn der Redmine-lokale Admin den gleichen Usernamen hat, wie der CAS-Admin)
- Darauf achten, dass evtl.e Breakpoints im Redmine-Repository unter `plugins/redmine_cas/.../*.rb` gesetzt werden

## Troubleshooting
### Probleme mit der automatischen Run-Configuration
1) IntelliJ schließen
2) gehen Sie zu den Projekt-Quelldateien und entfernen Sie den Ordner `.idea`.
3) starten Sie IntelliJ

### Probleme mit RVM
Bei einigen Installationsmethoden kann es zu fehlenden Berechtigungen kommen. Ändern Sie die Eigentümerschaft des rvm-Verzeichnisses, damit Bundler Zugriff auf die Ordner hat, die es für die Abhängigkeiten verwenden wird. 
`sudo chown [user]:[user] /usr/share/rvm`
