require 'role_model'

class User < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  include RoleModel

  has_many :monitored_resources, dependent: :destroy
  has_and_belongs_to_many :shared_resources, class_name: 'MonitoredResource' , join_table: 'monitored_resources_users'
  has_many :monitored_periods, dependent: :destroy

  # optionally set the integer attribute to store the roles in,
  # :roles_mask is the default
  roles_attribute :roles_mask

  # declare the valid roles -- do not change the order if you add more
  # roles later, always append them at the end!
  roles :admin, :google_user, :researcher
         
  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
     data = access_token.info
     credentials = access_token.credentials
     
     user = User.where(:email => data["email"]).first

     unless user
         user = User.create(name: data["name"],
              email: data["email"],
              uid: data["uid"],
              provider: data["provider"],
              token: credentials['token'],
              refresh_token: credentials['refresh_token'],
              expires_at: credentials['expires_at'],
              password: Devise.friendly_token[0,20],
              roles: [:google_user]
             )
     else
       user.token = credentials['token']
       user.expires_at = credentials['expires_at']
       user.save
     end
     user
 end
 
 def self.refresh_token!(current_user)
   # Refresh auth token from google_oauth2.
   options = {
     :client_id => GOOGLE['client_id'],
     :client_secret => GOOGLE['client_secret'],
     :refresh_token => "#{current_user.refresh_token}",
     :grant_type => 'refresh_token',
   }
   
   begin
     refresh = RestClient.post('https://accounts.google.com/o/oauth2/token', options)
   rescue Exception => e
     p e.inspect
     exit
   end

   if refresh.code == 200
     parsed_response = JSON::parse(refresh.body)
     current_user.token = parsed_response['access_token']
     current_user.expires_at = Time.now + parsed_response['expires_in'] - 5
     current_user.save
   end
 end
 
 def token_has_expired?
   Time.now.to_i >= self.expires_at
 end

 def my_resources
   [monitored_resources, shared_resources].flatten!
 end
 
 def monitored_resources_ids
   ids = []
   monitored_resources.each do |mr|
     ids << mr.gid
   end
   return ids
 end
 
end
