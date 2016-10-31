class RegistryUsageController < ApplicationController
  def search_registry
    # Make sure we have access to siteproperties so we can grab data from gui.properties
    siteproperties = session[:guiproperties]
    if siteproperties.nil?
      siteproperties = Guiproperties.new
      session[:guiproperties] = siteproperties
    end

    # Get current user or set to 'public'
    user = current_user.nil? ? "public" : current_user.login

    # Sometimes project id is passed as in the case for the project side bar
    project_id = params[:project_id]

    # Create a registry usage entry
    RegistryUsage.create(requestor_ip: request.ip, login: user, project_id: project_id)

    # Redirect to tomcat while passing the appropriate registry (default CAM), action and login
    redirect_path = siteproperties.getRegistryURL()+"&action=SEARCH&login=" + user
    redirect_path += "&prj_id=" + project_id if project_id.present?
    redirect_to redirect_path
  end

end
