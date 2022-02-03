desc 'Restore the default CAS connection settings and keep the users customizations'
namespace :redmine_cas do
  task :change_setting, [:key, :value] => [:environment] do | _, args |
    puts "==============================="
    puts "Set settings key '#{args.key}'"
    puts "Previous settings value: #{RedmineCAS.setting(args.key.to_sym)}"
    RedmineCAS.set_setting(args.key, args.value)
    puts "New settings value: #{RedmineCAS.setting(args.key.to_sym)}"
    puts "==============================="
  end

  task :get_setting, [:key] => [:environment] do | _, args |
    puts "Setting '#{args.key}' => #{RedmineCAS.setting(args.key.to_sym)}"
  end
end