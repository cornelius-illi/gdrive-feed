require 'rest_client'

class MonitoredResourcesController < ApplicationController
  #before_filter :authenticate_user!
  before_filter :refresh_token!
  before_action :set_monitored_resource, only: [:show, :permissions, :refresh_permissions,
                                                :reports, :permission_groups, :index_structure, :index_changehistory]
  
  def list
    @monitored_resources = current_user.monitored_resources
  end

  def new
    @folders = DriveFiles.retrieve_all_root_folders(current_user.token)
    @monitored_resources_ids = current_user.monitored_resources_ids
    @monitored_resources = current_user.monitored_resources # for navigation only
  end
  
  def create
      @monitored_resource = MonitoredResource.where(monitored_resource_params).first_or_create
      @monitored_resource.update_metadata(current_user.token)
      @monitored_resource.update_permissions(current_user.token)

      redirect_to @monitored_resource, :notice => "New monitored resource '#{@monitored_resource.title}' successfully created"
  end
  
  def show
  end

  def permissions
  end

  def refresh_permissions
    unless @monitored_resource.blank?
      @monitored_resource.update_permissions(current_user.token)
      redirect_to mr_permissions_path, :notice => "Permissions refreshed!"
    end
  end

  def permission_groups
    @permission_groups = PermissionGroup.find_by_monitored_resource_id(@monitored_resource.id)
  end

  def reports

  end

  def index_structure
    unless @monitored_resource.structure_indexed?
      #@monitored_resource.delay(:queue => 'index_structure', :owner => @monitored_resource).index_structure(current_user.id, current_user.token, 'root')
      @monitored_resource.index_structure(current_user.id, current_user.token, @monitored_resource.gid)
      redirect_to @monitored_resource
    else
      redirect_to @monitored_resource, :notice => "Structure has already been indexed on: #{@monitored_resource.structure_indexed_at.to_s(:db)}"
    end
  end

  def index_changehistory
    unless @monitored_resource.changehistory_indexed?
      @monitored_resource.index_changehistory()
    else
      redirect_to @monitored_resource, :notice => "Change History has already been indexed on: #{@monitored_resource.changehistory_indexed_at.to_s(:db)}"
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_monitored_resource
    @monitored_resource = MonitoredResource.where(:id => params[:id], :user_id => current_user.id).first
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def monitored_resource_params
    par = { :gid => params[:gid], :user_id => current_user.id }
  end
end