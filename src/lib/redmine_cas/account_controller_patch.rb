require 'redmine_cas'
CAS_URL = '/cas/login'

module RedmineCAS
  module AccountControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :logout_without_cas, :logout
        alias_method :logout, :logout_with_cas
        alias_method :original_login, :login
        alias_method :login, :cas_login
      end
    end

    module InstanceMethods
      def cas_login
        return original_login unless RedmineCAS.enabled?
        return unless RedmineCAS.setting(:redirect_enabled)

        prev_url = request.referrer
        prev_url = home_url if prev_url.to_s.strip.empty?
        login_url = CAS_URL + '?service=' + ERB::Util.url_encode(prev_url)
        redirect_to login_url
      end

      def logout_with_cas
        return logout_without_cas unless RedmineCAS.enabled?

        logout_user
        CASClient::Frameworks::Rails::Filter.logout(self, home_url)
      end

      def cas
        return redirect_to_action('login') unless RedmineCAS.enabled?

        if User.current.logged?
          # User already logged in.
          redirect_to home_url
          return
        end

        if CASClient::Frameworks::Rails::Filter.filter(self)
          user = User.find_by_login(session[:cas_user])
          ces_admin_group = ENV['ADMIN_GROUP']
          admin_group_exists = !ces_admin_group.nil?

          # Auto-create user
          if user.nil? && RedmineCAS.autocreate_users?
            user = User.new
            user.login = session[:cas_user]

            user.auth_source_id = 1
            user.assign_attributes(RedmineCAS.user_extra_attributes_from_session(session))
            return cas_user_not_created(user) unless user.save

            user.reload
          else
            user = User.find_by_login(session[:cas_user])
          end

          # Auto-create user's groups and/or add him/her
          @usergroups = Array.new
          session[:cas_extra_attributes].each do |i|
            next unless i[0] == 'allgroups'

            i[1].each do |j|
              @usergroups << j
              begin
                group = Group.find_by(lastname: j.to_s)
                if group.to_s == ''
                  # if group does not exist
                  # create group and add user
                  @newgroup = Group.new(lastname: j.to_s, firstname: 'cas')
                  @newgroup.users << user
                  @newgroup.save
                else
                  # if not already: add user to existing group
                  @groupusers = User.active.in_group(group).all
                  group.users << user unless @groupusers.include?(user)
                end
              rescue Exception => e
                logger.info e.message
              end
            end
            @casgroups = Group.where(firstname: 'cas')
            @casgroups.each do |l|
              @casgroup = Group.find_by(lastname: l.to_s)
              @casgroupusers = User.active.in_group(@casgroup).all
              if @casgroupusers.include?(user) && !@usergroups.include?(l.to_s)
                # remove user from group
                @casgroup.users.delete(user)
              end
            end
          end
          # Grant admin rights to user if he/she is in ces_admin_group
          # Revoke admin rights if they were granted by cas and not granted from a redmine administrator
          if admin_group_exists
            cas_admin_field = create_or_update_cas_admin_custom_field
            if @usergroups.include?(ces_admin_group.gsub("\n", ''))
              # only iterate the users custom fields if the user is no redmine internal admin
              update_cas_admin_value(user, 1) if is_false?(user.admin)
              user.update_attribute(:admin, 1)
            else
              # Only revoke admin permissions if they were originally set via CAS
              created_by_cas = user.custom_field_value(cas_admin_field).is_true?
              user.update_attribute(:admin, 0) if created_by_cas
              update_cas_admin_value(user, 0)
            end

            return cas_user_not_created(user) unless user.save
            user.reload

            cas_admin_field.validate_custom_field
            cas_admin_field.save!
          end

          return cas_user_not_found if user.nil?
          return cas_account_pending unless user.active?

          user.update_attribute(:last_login_on, Time.now)
          user.update(RedmineCAS.user_extra_attributes_from_session(session))
          if RedmineCAS.single_sign_out_enabled?
            # logged_user= would start a new session and break single sign-out
            User.current = user
            start_user_session(user)
          else
            self.logged_user = user
          end

          redirect_to_ref_or_default
        end
      end

      def redirect_to_ref_or_default
        default_url = url_for(params.permit(:ticket).merge(:ticket => nil))
        redirect_url = request.original_url
        if params.has_key?(:ref)
          # do some basic validation on ref, to prevent a malicious link to redirect
          # to another site.
          new_url = params[:ref]
          if /http(s)?:\/\/|@/ =~ new_url
            # evil referrer!
            redirect_url = default_url
          else
            redirect_url = request.base_url + params[:ref]
          end
        else
          redirect_url = default_url
        end
        redirect_to redirect_url unless redirect_url == request.original_url
      end

      def cas_account_pending
        render_custom_403 :message => l(:notice_account_pending)
      end

      def cas_user_not_found
        render_custom_403 :message => l(:redmine_cas_user_not_found, :user => session[:cas_user])
      end

      def cas_user_not_created(user)
        logger.error "Could not auto-create user: #{user.errors.full_messages.to_sentence}"
        render_custom_403 :message => l(:redmine_cas_user_not_created, :user => session[:cas_user], :reason => user.errors.full_messages.to_sentence)
      end

      def render_custom_403(options={})
        @project = nil
        render_custom_error({:message => :notice_not_authorized, :status => 403}.merge(options))
        false
      end

      def render_custom_error(arg)
        arg = {:message => arg} unless arg.is_a?(Hash)

        @message = arg[:message]
        @message = l(@message) if @message.is_a?(Symbol)
        @status = arg[:status] || 500

        respond_to do |format|
          format.html do
            render :template => 'redmine_cas/custom_error', :layout => use_layout, :status => @status
          end
          format.any {head @status}
        end
      end

      def is_false?(value)
        !value || value == false || value.nil? || value.to_s == 'false' || value == 0
      end

      def update_cas_admin_value(user, new_value)
        user.custom_field_values.each do |field|
          field.value = new_value if field.custom_field.name == 'casAdmin'
        end
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
    end
  end
end
