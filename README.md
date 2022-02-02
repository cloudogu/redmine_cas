# Redmine CAS plugin

Plugin to CASify your Redmine installation. 
This fork is highly optimized to work inside of the [Cloudogu EcoSystem](https://github.com/cloudogu/ecosystem).

## Compatibility

Tested with Redmine 3.x.x and 4.x.x but it should work fine with Redmine 2.x and possibly 1.x.
We use our [CAS-Dogu](https://github.com/cloudogu/cas) as CAS server, but it might work with others as well.

## Installation

1. Download or clone this repository
2. Execute the `bundle/bundle_plugin.rb`-script and place the generated folder in the Redmine `plugins` directory as `redmine_cas`
3. Configure your redmine environment
   1. Export the "FQDN=xxx"-Environment-Variable: The host where your cas installation is running.
      1. Note that the CAS must be available under `https://<FQDN>/cas`, otherwise it won't work.
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

## Copyright

Copyright (c) 2013-2014 Nine Internet Solutions AG. See LICENSE.txt for further details.
