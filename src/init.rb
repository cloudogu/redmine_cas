require 'redmine'
require 'redmine_cas'
require 'redmine_cas/application_controller_patch'
require 'redmine_cas/account_controller_patch'

require_dependency 'redmine_cas_hook_listener'

Redmine::Plugin.register :redmine_cas do
  name 'Redmine CAS plugin'
  author 'Robert Auer (Cloudogu GmbH)'
  description 'Plugin to CASify your Redmine installation.'
  version '1.5.2'
  url 'https://github.com/cloudogu/redmine_cas'

  settings :default => {
    'enabled' => false,
    'attributes_mapping' => 'firstname=givenName&lastname=surname&mail=mail&login=username&allgroups=allgroups',
    'redmine_fqdn' => '192.168.56.2',
    'cas_fqdn' => '192.168.56.2',
    'cas_relative_url' => '/cas',
  }, :partial => 'redmine_cas/settings'

  Rails.configuration.to_prepare do
    ApplicationController.send(:include, RedmineCAS::ApplicationControllerPatch)
    AccountController.send(:include, RedmineCAS::AccountControllerPatch)
    User.send(:include, RedmineCAS::UserPatch)
  end
  ActionDispatch::Callbacks.before do
    RedmineCAS.setup!
  end
end
