require 'casclient'
require 'casclient/frameworks/rails/filter'
require 'redmine'

class String
  def is_true?()
    if self == "true" || self == "1"
      true
    else
      false
    end
  end
end

class NilClass
  def is_true?()
    true
  end
end

module RedmineCAS
  extend self

  def setting(name)
    Setting.plugin_redmine_cas[name]
  end

  def enabled?
    setting(:enabled)
  end

  def autocreate_users?
    setting(:autocreate_users)
  end

  def setup!
    return unless enabled?

    CASClient::Frameworks::Rails::Filter.configure(
      cas_base_url: setting(:cas_url),
      logger: Rails.logger,
      validate_url: setting(:cas_url) + '/p3/proxyValidate',
      enable_single_sign_out: single_sign_out_enabled?
    )
    auth_source = AuthSource.find_by_type('AuthSourceCas')
    create_cas_auth_source if auth_source.nil?
  end

  def single_sign_out_enabled?
    ActiveRecord::Base.connection.table_exists?(:sessions)
  end

  def user_extra_attributes_from_session(session)
    attrs = {}
    map = Rack::Utils.parse_nested_query setting(:attributes_mapping)
    extra_attributes = session[:cas_extra_attributes] || {}
    map.each_pair do |key_redmine, key_cas|
      value = extra_attributes[key_cas]
      if User.attribute_method?(key_redmine) && value
        attrs[key_redmine] = (value.is_a? Array) ? value.first : value
      end
    end
    attrs
  end

  private

  # Creates the auth_source used by CAS to identify users created by CAS.
  def create_cas_auth_source
    # type is the only value which is used by the plugin to assign the CAs auth_source to new users
    # the other values are just required by the database scheme
    Rails.logger.warn 'add cas auth source'
    auth_source = AuthSource.create(
      type: 'AuthSourceCas',
      name: 'Cas',
      host: 'cas.example.com',
      port: 1234,
      account: 'myDbUser',
      account_password: 'myDbPass',
      base_dn: 'dbAdapter:dbName',
      attr_login: 'name',
      attr_firstname: 'firstName',
      attr_lastname: 'lastName',
      attr_mail: 'email',
      onthefly_register: true,
      tls: false,
      filter: nil,
      timeout: nil
    )
    auth_source.save
  end
end
