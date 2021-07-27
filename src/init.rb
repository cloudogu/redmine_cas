# This serves only the purpose of making development with easy redmine less painful as it enables one to develop
# this plugin and (re)start it via the apply.sh script. Otherwise you need to do a full build of EasyRedmine as the copy
# of the init.rb is part of the Dockerfile.
if ENV['RAILS_RELATIVE_URL_ROOT'] == "/easyredmine"
  RedmineExtensions::Reloader.to_prepare do
    require 'redmine'
    require 'redmine_cas'
    require 'redmine_cas/application_controller_patch'
    require 'redmine_cas/account_controller_patch'

    require_dependency 'redmine_cas_hook_listener'
  end
end

Redmine::Plugin.register :redmine_cas do
  name 'Redmine CAS plugin'
  author 'Robert Auer (Cloudogu GmbH)'
  description 'Plugin to CASify your Redmine installation.'
  version '1.4.0'
  url 'https://github.com/cloudogu/redmine_cas'

  settings :default => {
    'enabled' => false,
    'cas_url' => 'https://',
    'attributes_mapping' => 'firstname=first_name&lastname=last_name&mail=email',
    'autocreate_users' => false
  }, :partial => 'redmine_cas/settings'

  Rails.configuration.to_prepare do
    ApplicationController.send(:include, RedmineCAS::ApplicationControllerPatch)
    AccountController.send(:include, RedmineCAS::AccountControllerPatch)
  end
  ActionDispatch::Callbacks.before do
    RedmineCAS.setup!
  end
end
