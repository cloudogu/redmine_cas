module RedmineCAS
  module UserManager
    def add_user_to_group(groupname, user)
      begin
        logger.info "add_user_to_group: " + groupname + ", " + user.to_s
        @group = Group.find_by(lastname: groupname)
        if @group == nil
          # create group and add user
          create_group_with_user(groupname, user)
        else
          logger.info 'group "' + @group.to_s + '" already exists'

          # if not already: add user to existing group
          @groupusers = User.active.in_group(@group).all()
          if not (@groupusers.include?(user))
            logger.info 'add "' + user.to_s + '" to group ' + @group.to_s
            @group.users << user
            @group.save
          else
            logger.info '"' + user.to_s + '" is already member of "' + @group.to_s + '"'
          end
        end
      rescue Exception => e
        logger.info e.message
      end
    end

    def create_or_update_user(login, user_givenName, user_surname, user_mail, user_groups, auth_source_id)
      # Get ces admin group
      admin_group_exists = false
      if CES_ADMIN_GROUP != ''
        admin_group_exists = true
      end

      user = User.find_by_login(login)
      if user == nil # user not in redmine yet

        user = User.new
        user.login = login
        user.firstname = user_givenName
        user.lastname = user_surname
        user.mail = user_mail
        user.auth_source_id = auth_source_id
        if admin_group_exists
          if user_groups.to_s.include?(CES_ADMIN_GROUP.gsub('\n', ''))
            user.admin = 1
          end
        end

        for i in user_groups
          # create group / add user to group
          add_user_to_group(i.to_s, user)
        end unless user_groups.nil?

        if !user.save
          raise user.errors.full_messages.to_s
        end
      else
        # user already in redmine
        @usergroups = Array.new
        for i in user_groups
          @usergroups << i.to_s
          # create group / add user to group
          add_user_to_group(i.to_s, user)
        end unless user_groups.nil?

        # remove user from groups he is not in any more
        @casgroups = Group.where(firstname: 'cas')
        for l in @casgroups
          @casgroup = Group.find_by(lastname: l.to_s)
          @casgroupusers = User.active.in_group(@casgroup).all()
          for m in @casgroupusers
            if (m.login == login) and not (@usergroups.include?(l.to_s))
              @casgroup.users.delete(user)
            end
          end
        end

        # remove user's admin rights if he is not in admin group any more
        cas_admin_field = UserCustomField.find_by_name('casAdmin')
        created_by_cas = user.custom_field_value(cas_admin_field).is_true?
        if admin_group_exists and created_by_cas
          if user_groups.to_s.include?(CES_ADMIN_GROUP.gsub('\n', ''))
            user.admin = 1
          else
            user.admin = 0
          end
          user.save
        end
      end

      user
    end

    def create_group_with_user(group, user)
      logger.info 'create new group "' + group + '" and add member "' + user.to_s + '"'
      # create group and add user
      @newgroup = Group.new(:lastname => group, :firstname => 'cas')
      @newgroup.users << user
      @newgroup.save!
    end
  end
end