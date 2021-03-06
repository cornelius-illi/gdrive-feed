module DriveFiles
  FIELDS_FILES_GET = 'alternateLink,iconLink,exportLinks,createdDate,md5Checksum,fileExtension,fileSize,kind,ownerNames,owners/permissionId,parents/id,lastModifyingUserName,mimeType,modifiedDate,shared,sharedWithMeDate,title,labels(trashed,viewed)'
  FIELDS_FILES_LIST = 'items(id,' + FIELDS_FILES_GET + ')'
  FIELDS_PERMISSIONS_GET = 'domain,emailAddress,etag,id,kind,name,role,type,value'
  FIELDS_PERMISSIONS_LIST = 'items(' + FIELDS_PERMISSIONS_GET + ')'

  # @todo: refactor: files -> resources

  def self.retrieve_all_root_folders(user_token)
    query = "'root' in parents AND mimeType='application/vnd.google-apps.folder'" # AND sharedWithMe"
    return self.gdrive_api_file_list(query, user_token)
  end
  
  def self.retrieve_all_files_for(gid, user_token)
    # "and trashed = false" ... to only retrieve files available to user
    # use garbage collection to mark as unavailable=1 for files that do not occur anymore
    query = "'#{gid}' in parents and trashed = false"
    return self.gdrive_api_file_list(query, user_token)
  end
  
  def self.retrieve_file_metadata(gid, user_token)
    return self.gdrive_api_file_get(gid, user_token)
  end
  
  def self.retrieve_file_permissions(gid, user_token)
    return self.gdrive_api_permission_list(gid, user_token)
  end

  def self.retrieve_permission(fileId,permissionId, user_token)
    return self.gdrive_api_permission_get(fileId, permissionId, user_token)
  end

  def self.download(url, user_token)
    return self.gdrive_api_download(url, user_token)
  end
  
  private
  def self.gdrive_api_file_list(query, user_token)
    response = RestClient.get 'https://www.googleapis.com/drive/v2/files', {:params => {
      :key => GOOGLE['client_secret'], 
      :access_token => user_token,
      :q => query,
      :fields => FIELDS_FILES_LIST }}
    response = JSON::parse(response)
    return response["items"]
  end
  
  def self.gdrive_api_file_get(file_id, user_token)
    RestClient.get("https://www.googleapis.com/drive/v2/files/#{file_id}", {:params => {
        :key => GOOGLE['client_secret'],
        :access_token => user_token,
        :fields => FIELDS_FILES_GET }}){ |response, request, result, &block|
      case response.code
        when 200
          return JSON::parse(response)
        when 404
          return nil
        else
          response.return!(request, result, &block)
      end
    }
  end
  
  def self.gdrive_api_permission_list(file_id, user_token)
    response = RestClient.get "https://www.googleapis.com/drive/v2/files/#{file_id}/permissions", {:params => {
      :key => GOOGLE['client_secret'], 
      :access_token => user_token,
      :fields => FIELDS_PERMISSIONS_LIST }}
      response = JSON::parse(response)
      return response["items"]
  end

  def self.gdrive_api_permission_get(file_id, permission_id, user_token)
    response = RestClient.get "https://www.googleapis.com/drive/v2/files/#{file_id}/permissions/#{permission_id}", {:params => {
        :key => GOOGLE['client_secret'],
        :access_token => user_token,
        :fields => FIELDS_PERMISSIONS_GET }}
    response = JSON::parse(response)
    return response
  end

  def self.gdrive_api_download(url,user_token)
    # can throw -> RestClient::Unauthorized: 401 Unauthorized or 404
    begin
      resource = RestClient::Resource.new(url)
      return resource.get( :Authorization => 'Bearer ' + user_token)
    rescue Exception => e
      failed_download_logger ||= Logger.new("#{Rails.root}/log/failed_downloads.log")
      failed_download_logger.error("Could not download ''" + url + "'. Error:" + e.message)
      return nil
    end
  end
end