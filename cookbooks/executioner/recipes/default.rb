if node[:instance_role] =~ /^app/

  remote_file "/engineyard/bin/executioner" do
    source "executioner"
    owner "root"
    group "root"
    mode 0755
  end

  node[:applications].each do |app_name,data|
    1.times do |count| # TODO: Use multiple copiers later
      template "/etc/monit.d/executioner#{count+1}.#{app_name}.monitrc" do
        source "executioner.monitrc.erb"
        owner "root"
        group "root"
        mode 0644
        variables({
          :app_name => app_name,
          :user => node[:owner_name],
          :worker_name => "executioner#{count+1}",
          :framework_env => node[:environment][:framework_env]
        })
      end
    end

    execute "monit-reload-restart" do
       command "sleep 30 && monit reload"
       action :run
    end
  end
end
