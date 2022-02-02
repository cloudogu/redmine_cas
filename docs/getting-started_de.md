# Entwicklung des Redmine CAS-Plugins

## Lokale Einrichtung zum Debuggen

### EcoSystem einrichten
- Ein EcoSystem lokal mit vagrant aufsetzen (`https://github.com/cloudogu/ecosystem`)
- Cas-Dogu in den development mode bringen
  - `etcdctl set config/_global/stage development`
  - `docker restart cas`

### Ruby und Builder mit rvm installieren
- `https://github.com/rvm/rvm`.
  Derzeit wird die Entwicklung mit ruby 2.7.4 durchgeführt
  Version wechseln `rvm use 2.7.4` (Das muss in jeder Terminal-Instanz erneut durchgeführt werden sowie ggf. in der IDE)

### rubycas-client vorbereiten
- Das ist notwendig, um in einem lokal aufgesetzten Redmine das CAS-Plugin nutzen zu können
- Auschecken des Redmine-Quellcodes `git clone https://github.com/cloudogu/rubycas-client.git`
- Mit dem Terminal in das Verzeichnis des Plugins wechseln
- Darauf achten, dass mit `rvm use` die richtige ruby-version ausgewählt ist
- Das Plugin bauen mit `gem build rubycas-client.gemspec`
- Das Plugin installieren mit `gem install rubycas-client`

### Redmine-Einrichtung
- Auschecken des Redmine-Quellcodes `git clone https://github.com/redmine/redmine.git`
- Auschecken der aktuell verwendeten Redmine-Dogu-Version (z.B. `git checkout 4.2.3`)
- Das cas-plugin in diesem Repository bauen mit `bundle/bundle_plugin.rb`
- Das gebaute cas-plugin in den `<path-to-redmine>/plugins`-Ordner ablegen
- Als `config.database.yml` folgende Datei anlegen:
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
- Mit dem Terminal in das Verzeichnis von Redmine wechseln
- Darauf achten, dass mit `rvm use` die richtige ruby-version ausgewählt ist
- Bundler installieren mit `gem install bundler`
- Dependencies installieren mit `bundle install`
- Datenbankmigration durchführen mit `RAILS_ENV=development bundle exec rake db:migrate`
- Mit `rails server` kann jetzt Redmine lokal gestartet werden

### Einrichtung für Debugging in der IDE (intellij)
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
  - Ist das nicht erfolgt, hat sich Intellij falsch initialisiert
  - Die beste Lösung für den Fall ist es, Redmine erneut auszuchecken und wieder bei `Redmine-Einrichtung` zu beginnen
- Die Run-Konfigurationen auswählen und anpassen
  - Richtige ruby-version auswählen
- Es sollte in etwa so aussehen:
![run-config](figures/getting-started/run-configuration.png)
- Konfiguration für lokales EcoSystem einrichten
- `rake redmine_cas:change_setting\[admin_group,<your-admin-group>\]`
- `rake redmine_cas:change_setting\[redmine_fqdn,192.168.56.2\]`
- `rake redmine_cas:change_setting\[cas_fqdn,192.168.56.2\]`
- `rake redmine_cas:change_setting\[cas_relative_url,/cas\]`
- `rake redmine_cas:change_setting\[enabled,1\]`
- Jetzt kann über die Run-Konfiguration Redmine gestartet werden, auch im debug-Modus




## Troubleshooting
### Probleme mit der automatischen Run-Configuration
1) intellij schließen
2) gehen Sie zu den Projekt-Quelldateien und entfernen Sie den Ordner `.idea`.
3) starten Sie intellij

### Probleme mit RVM
Bei einigen Installationsmethoden kann es zu fehlenden Berechtigungen kommen. Ändern Sie die Eigentümerschaft des rvm-Verzeichnisses, damit Bundler Zugriff auf die Ordner hat, die es für die Abhängigkeiten verwenden wird. sudo chown [user]:[user] /usr/share/rvm`
