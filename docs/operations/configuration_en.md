# Configuration of the CAS plugin

## Settings
For a fully functional CAS plugin, the following configurations must be set up correctly:

### enabled
Values: 0 | 1
Effect: Switches the plugin off or on.

### attributes_mapping
Values: `<redmine-attribute>=<cas-attribute>&<redmine-attribute>=<cas-attribute>` (e.g. `firstname=givenName&lastname=surname&mail=mail&login=username&allgroups=allgroups`)
Effect: Corresponds to the mapping of the user attributes of Redmine=>Cas

### redmine_fqdn
Values: IP / hostname
Effect: Used to redirect to Redmine. Must match the FQDN of the Redmine installation.

### redmine_fqdn
Values: IP / hostname
Effect: Used to redirect to CAS. Must match the FQDN of the CAS installation.

### cas_relative_url
Values: String (URL) (e.g. `/cas`)
Effect: context path of CAS, used in conjunction with the FQDN to redirect to CAS.

### local_users_enabled
Values: 0 | 1
Effect: If 0, login with local users is prohibited, if 1, login with local users is allowed.

### admin_group
Values: String
Effect: This value specifies the group name of a group whose members will automatically become the administrator.

## Rake task for displaying / changing settings

### Change
With the rake task `rake redmine_cas:change_setting\[<key>,<value>\]` a setting can be changed.
An output appears that looks something like this:
```
Previous settings value: /cas
New settings value: /cas2
```

### Display
With the rake task `rake redmine_cas:get_setting\[<key>\]` a setting can be displayed.
An output appears that looks something like this:
```
Setting 'cas_relative_url' => /cas
```

## Other configuration

### ENV['AUTO_MANAGED']
This environment variable can be exported before Redmine startup to achieve a specific behavior.

Values: String ("true" | "false")
Effect: If set to "true", no value can be changed in the settings except `enabled` and `local_users_enabled`.
