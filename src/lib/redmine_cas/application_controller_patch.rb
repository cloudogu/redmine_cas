require 'redmine_cas'

module RedmineCAS
  module ApplicationControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method :verify_authenticity_token_without_cas, :verify_authenticity_token
        alias_method :verify_authenticity_token, :verify_authenticity_token_with_cas
        alias_method :require_login_without_cas, :require_login
        alias_method :require_login, :require_login_with_cas
        alias_method :original_check_if_login_required, :check_if_login_required
        alias_method :check_if_login_required, :cas_check_if_login_required

        alias_method :original_find_current_user, :find_current_user
        alias_method :find_current_user, :cas_find_current_user
      end
    end

    module InstanceMethods
      FQDN = ENV['FQDN']

      def cas_find_current_user
        if /\AProxyTicket /i.match?(request.authorization.to_s)
          begin
            ticket = request.authorization.to_s.split(" ", 2)[1]
            service = "https://#{FQDN}/redmine"
            pt = CASClient::ServiceTicket.new(ticket, service)
            validationResponse = CASClient::Frameworks::Rails::Filter.client.validate_proxy_ticket(pt)
            if validationResponse.success
              login = validationResponse.user

              userAttributes = validationResponse.extra_attributes
              user_mail = userAttributes["mail"]
              user_surname = userAttributes["surname"]
              user_givenName = userAttributes["givenName"]
              user_groups = userAttributes["allgroups"]

              cas_auth_source = AuthSource.find_by(:name => 'Cas')
              user = cas_auth_source.create_or_update_user(login, user_givenName, user_surname, user_mail, user_groups, cas_auth_source.id)

              return user
            end
          rescue => e
            puts "error while validating proxy ticket"
            puts e.to_s
          end
        end

        return original_find_current_user
      end

      def require_login_with_cas
        return require_login_without_cas unless RedmineCAS.enabled?

        if !User.current.logged?
          referrer = request.fullpath;
          respond_to do |format|
            # pass referer to cas action, to work around this problem:
            # https://github.com/ninech/redmine_cas/pull/13#issuecomment-53697288
            format.html { redirect_to :controller => 'account', :action => 'cas', :ref => referrer }
            format.atom { redirect_to :controller => 'account', :action => 'cas', :ref => referrer }
            format.xml { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
            format.js { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
            format.json { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
          end
          return false
        end
        # this code was added to remove the ticket parameter in url when it is not necessary
        if params.has_key?(:ticket)
          default_url = url_for(params.permit(:ticket).merge(:ticket => nil))
          redirect_to default_url
        end
        true
      end

      def cas_check_if_login_required
        return original_check_if_login_required unless RedmineCAS.enabled?
        require_login if params.has_key?(:ticket) or original_check_if_login_required
      end

      def verify_authenticity_token_with_cas
        if cas_logout_request?
          logger.info 'CAS logout request detected: Skipping validation of authenticity token'
        else
          verify_authenticity_token_without_cas
        end
      end

      def cas_logout_request?
        request.post? && params.has_key?('logoutRequest')
      end

    end
  end
end
