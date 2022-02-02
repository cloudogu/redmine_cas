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

class BasicObject
  def is_false?()
    !self || self == false || self.nil? || self.to_s == 'false' || self == 0
  end
end

module RedmineCAS
  extend self

  def setting(name)
    Setting[:plugin_redmine_cas][name.to_sym]
  end

  def set_setting(name, value)
    settings = Setting.plugin_redmine_cas
    settings[name.to_sym] = value
    Setting.set_all_from_params({ plugin_redmine_cas: settings })
  end

  def self.get_attribute_mapping
    mapping = RedmineCAS.setting(:attributes_mapping)
    Rack::Utils.parse_nested_query(mapping)
  end

  def self.get_cas_url
    fqdn=RedmineCAS.setting(:cas_fqdn)
    relative=RedmineCAS.setting(:cas_relative_url)
    "https://#{fqdn}#{relative}"
  end

  def self.get_redmine_url
    fqdn=RedmineCAS.setting(:redmine_fqdn)
    relative=ENV['RAILS_RELATIVE_URL_ROOT']
    "https://#{fqdn}#{relative}"
  end

  def self.get_admin_group
    RedmineCAS.setting(:admin_group)
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
      cas_base_url: RedmineCAS.get_cas_url,
      logger: Rails.logger,
      validate_url: RedmineCAS.get_cas_url + '/p3/proxyValidate',
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
    mapping=self.get_attribute_mapping
    extra_attributes = session[:cas_extra_attributes] || {}
    mapping.each_pair do |key_redmine, key_cas|
      value = extra_attributes[key_cas]
      if value
        attrs[key_redmine] = value
      end
    end

    attrs
  end

  def create_or_update_cas_admin_custom_field
    # Get custom field which indicates if the admin permissions of the user were set via cas
    cas_admin_field = UserCustomField.find_by_name('casAdmin')
    # Create custom field if it doesn't exist yet
    if cas_admin_field == nil
      cas_admin_field = UserCustomField.new
      cas_admin_field.field_format = 'bool'
      cas_admin_field.name = 'casAdmin'
      cas_admin_field.description = 'Indicates if admin permissions were granted via cas; do not delete!'
    end
    cas_admin_field.edit_tag_style = 'check_box'
    cas_admin_field.visible = 0
    cas_admin_field.editable = 0
    cas_admin_field.validate_custom_field
    cas_admin_field.save!

    cas_admin_field
  end

  def self.api_request(uri, form_data)
    http_uri = URI.parse(uri)
    http = Net::HTTP.new(http_uri.host, http_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(http_uri.path, initheader = { 'Content-Type' => 'application/json' })
    request.set_form_data(form_data)

    http.request(request)
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
