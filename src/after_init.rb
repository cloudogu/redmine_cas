require 'redmine_cas'
require 'redmine_cas/application_controller_patch'
require 'redmine_cas/account_controller_patch'
require 'redmine_cas/user_patch'

# ApplicationController defines the methods the patch overrides, so it has to be prepended.
# Included, the controller's own methods would win and CAS would silently do nothing.
EasyPatchManager.register_controller_patch 'ApplicationController', 'RedmineCas::ApplicationControllerPatch', prepend: true
EasyPatchManager.register_controller_patch 'AccountController', 'RedmineCas::AccountControllerPatch'
EasyPatchManager.register_model_patch 'User', 'RedmineCas::UserPatch'

ActiveSupport::Reloader.to_prepare do
  require 'redmine_cas/redmine_cas_hook_listener'
end

# Outside to_prepare, or every code reload in development would register another callback.
ActionDispatch::Callbacks.before do
  RedmineCas.setup! if Rails.env.production?
end
