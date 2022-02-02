# Konfiguration des CAS-Plugins

## Settings
Für ein voll funktionsfähiges CAS-Plugin müssen folgende Konfigurationen korrekt eingerichtet sein:

### enabled
Werte: 0 | 1 
Effekt: Schaltet das Plugin aus bzw. ein.

### attributes_mapping
Werte: `<redmine-attribute>=<cas-attribute>&<redmine-attribute>=<cas-attribute>` (z.B `firstname=givenName&lastname=surname&mail=mail&login=username&allgroups=allgroups`)
Effekt: Entspricht dem Mapping der User-Attribute von Redmine=>Cas

### redmine_fqdn
Werte: IP / Hostname
Effekt: Wird verwendet, um auf Redmine weiterzuleiten. Muss der FQDN der Redmine-Installation entsprechen.

### redmine_fqdn
Werte: IP / Hostname
Effekt: Wird verwendet, um auf CAS weiterzuleiten. Muss der FQDN der CAS-Installation entsprechen.

### cas_relative_url
Werte: String (URL) (z.B. `/cas`)
Effekt: Kontextpfad von CAS, wird im Zusammenhang mit der FQDN verwendet, um auf CAS weiterzuleiten.

### local_users_enabled
Werte: 0 | 1
Effekt: Bei 0 wird der Login mit lokalen Nutzern verboten, bei 1 erlaubt.

### admin_group
Werte: String
Effekt: Dieser Wert bestimmt den Gruppennamen einer Gruppe, deren Mitglieder automatisch zum Administrator werden.

## Sonstige Konfiguration

### ENV['AUTO_MANAGED']
Diese Umgebungsvariable kann vor dem Redmine-Start exportiert werden, um ein bestimmtes Verhalten zu erzielen.

Werte: String ("true" | "false")
Effekt: Ist der Wert auf "true" gesetzt, kann außer `enabled` und `local_users_enabled` kein Wert in den Einstellungen verändert werden.
