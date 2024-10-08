require 'redmine'

Redmine::Plugin.register :redmine_cas do
  name 'Redmine CAS plugin'
  author 'hallo@cloudogu.com (Cloudogu GmbH)'
  description 'Plugin to CASify your Redmine installation.'
  version '2.2.0'
  url 'https://github.com/cloudogu/redmine_cas'

  settings :default => {
    'enabled' => 1,
    'attributes_mapping' => 'firstname=givenName&lastname=surname&mail=mail&login=username&allgroups=allgroups',
    'redmine_fqdn' => '192.168.56.2',
    'cas_fqdn' => '192.168.56.2',
    'cas_relative_url' => '/cas',
    'local_users_enabled' => 1,
    'admin_group' => 'admin',
  }, :partial => 'redmine_cas/settings'

  unless Module.const_defined?(:RedmineExtensions) then
    ApplicationController.send(:include, RedmineCas::ApplicationControllerPatch)
    AccountController.send(:include, RedmineCas::AccountControllerPatch)
    User.send(:include, RedmineCas::UserPatch)

    ActionDispatch::Callbacks.before do
      RedmineCas.setup!
    end
  end

end
