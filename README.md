# Redmine CAS plugin

Plugin to CASify your Redmine installation. 
This fork is highly optimized to work inside of the [Cloudogu EcoSystem](https://github.com/cloudogu/ecosystem).

## Compatibility

Tested with Redmine 5.0.x, 3.x.x and 4.x.x but it should work fine with Redmine 2.x and possibly 1.x.
We use our [CAS-Dogu](https://github.com/cloudogu/cas) as CAS server, but it might work with others as well.

### Important
This plugin requires our updated rubycas-client as the original one was not updated since 2013.
You can find the updated rubycas-client her: https://github.com/cloudogu/rubycas-client

## Installation

1. Download or clone this repository
2. Execute the `bundle/bundle_plugin.rb`-script and place the generated folder in the Redmine `plugins` directory as `redmine_cas`
3. Configure your redmine environment
   1. Export the "FQDN=xxx"-Environment-Variable: The host where your cas installation is running.
      1. Note that the CAS must be available under `https://<FQDN>/cas`, otherwise it won't work.
      2. The cas must also respond with the following user-attributes:
         1. "givenName": Users first name.
         2. "surname": Users last name.
         3. "mail": Users e-mail.
         4. "username": Users login.
         5. "allgroups": All groups of the user.
   2. Export the "ADMIN_GROUP=xxx"-Environment-Variable: Users in this group automatically gain admin permissions.
4. Restart your webserver
5. Open Redmine and check if the plugin is visible under Administration > Plugins
6. Follow the "Configure" link and set the parameters
7. Party

## Development in EcoSystem
You can use the scripts inside the `dev`-folder to quickly install this plugin 

1. Place this repository somewhere inside the EcoSystem
2. Navigate to the `dev` folder   
3. Execute `./apply.sh <doguname>` to install this plugin for a dogu (redmine/easyredmine)
4. If you want to see extended logs (production.log), execute `logs.sh <doguname>` 

### Development with Easyredmine
Easyredmine and Redmine have different ideas about how an `init.rb` file for a plugin should be structured, especially how the imports of the dependencies for the plugin should be loaded. The `init.rb` in this plugin is tailored for redmine.
Therefore, when testing locally with easyredmine, the `init.rb` must be overwritten (please do not commit your changes to `init.rb`) so that it encapsulates the `require` statements like this:
```ruby
RedmineExtensions::Reloader.to_prepare do
    require 'redmine'
    require 'redmine_cas'
    require 'redmine_cas/application_controller_patch'
    require 'redmine_cas/account_controller_patch'
    
    require_dependency 'redmine_cas_hook_listener'
end
```
After this is done you can proceed with testing as described above. 
## Notes
### Usage

If your installation has no public areas ("Authentication required") and you are not logged in, you will be
redirected to the CAS-login page.  The default login page will still work when you access it directly 
(http://example.com/path-to-redmine/login).

If your installation is not "Authentication required", the login page will show a link that lets you login
with CAS.

### Single Sign Out, Single Logout

The sessions have to be stored in the database to make Single Sign Out work.
You can achieve this with a tiny plugin: [redmine_activerecord_session_store](https://github.com/pencil/redmine_activerecord_session_store)

## What is the Cloudogu EcoSystem?
The Cloudogu EcoSystem is an open platform, which lets you choose how and where your team creates great software. Each service or tool is delivered as a Dogu, a Docker container. Each Dogu can easily be integrated in your environment just by pulling it from our registry.

We have a growing number of ready-to-use Dogus, e.g. SCM-Manager, Jenkins, Nexus Repository, SonarQube, Redmine and many more. Every Dogu can be tailored to your specific needs. Take advantage of a central authentication service, a dynamic navigation, that lets you easily switch between the web UIs and a smart configuration magic, which automatically detects and responds to dependencies between Dogus.

The Cloudogu EcoSystem is open source and it runs either on-premises or in the cloud. The Cloudogu EcoSystem is developed by Cloudogu GmbH under [AGPL-3.0-only](https://spdx.org/licenses/AGPL-3.0-only.html).

## License
Copyright © 2020 - present Cloudogu GmbH
This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License as published by the Free Software Foundation, version 3.
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details.
You should have received a copy of the GNU Affero General Public License along with this program. If not, see https://www.gnu.org/licenses/.
See [LICENSE](LICENSE) for details.


---
MADE WITH :heart:&nbsp;FOR DEV ADDICTS. [Legal notice / Imprint](https://cloudogu.com/en/imprint/?mtm_campaign=ecosystem&mtm_kwd=imprint&mtm_source=github&mtm_medium=link)

