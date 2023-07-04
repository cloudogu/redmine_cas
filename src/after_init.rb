RedmineExtensions::Reloader.to_prepare do
  require 'redmine_cas'
  require 'redmine_cas/application_controller_patch'
  require 'redmine_cas/account_controller_patch'

  require 'redmine_cas/redmine_cas_hook_listener'


  ApplicationController.send(:include, RedmineCas::ApplicationControllerPatch)
  AccountController.send(:include, RedmineCas::AccountControllerPatch)
  User.send(:include, RedmineCas::UserPatch)

end

ActionDispatch::Callbacks.before do
  RedmineCas.setup!
end

