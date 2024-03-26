RedmineExtensions::Reloader.to_prepare do
  ApplicationController.send(:include, RedmineCas::ApplicationControllerPatch)
  AccountController.send(:include, RedmineCas::AccountControllerPatch)
  User.send(:include, RedmineCas::UserPatch)
end

ActionDispatch::Callbacks.before do
  RedmineCas.setup!
end

