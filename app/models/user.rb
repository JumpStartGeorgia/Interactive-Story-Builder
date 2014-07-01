class User < ActiveRecord::Base
  # part of liking system
  acts_as_voter

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	# :registerable, :recoverable,
  has_and_belongs_to_many :stories

	has_one :local_avatar,     
	  :conditions => "asset_type = #{Asset::TYPE[:user_avatar]}", 	 
	  foreign_key: :item_id,
    class_name: "Asset",
	  dependent: :destroy

	accepts_nested_attributes_for :local_avatar, :reject_if => lambda { |c| c[:asset].blank? }

  devise :database_authenticatable,:registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, 
                  :provider, :uid, :nickname, :avatar,
                  :about, :default_story_locale, :permalink, :local_avatar_attributes, :avatar_file_name, :email_no_domain
  
  has_permalink :create_permalink, true

  validates :role, :presence => true

  ROLES = {:user => 0, :staff_pick => 50, :admin => 99}

  before_create :create_email_no_domain
  before_save :check_nickname_changed
	before_save :generate_avatar_file_name


  # email_no_domain is used in the search for collaborators 
  # so people cannot search using domain name to guess their email addresses
  def create_email_no_domain
    self.email_no_domain = self.email.split('@').first
  end

  # if the nickname changes, then the permalink must also change
  def check_nickname_changed
    if self.nickname_changed?
      # make sure there are no tags in the nickname
      self.nickname = ActionController::Base.helpers.strip_links(self.nickname)
      self.generate_permalink! 
    end
  end

  def create_permalink
    self.nickname.dup
  end

  # see if the user logs in via a provider (e.g., facebook)
  # and has an avatar url from that provider
  def has_provider_avatar?
    self.provider.present? && self.avatar.present?
  end
  
  # see if the user has a local avatar saved
  def local_avatar_exists?
    self.local_avatar.present? && self.local_avatar.asset.exists?
  end

  # get the url to the avatar
  # - check if using a provider and if so return that avatar url
  # - else use the local avatar
  # if neither exists, return the missing url
  def avatar_url(style = :'28x28')
    if has_provider_avatar? && !local_avatar_exists?
      # append the size to the end of the avatar url so the provider returns the size we want
      sizes = style.to_s.split('x')
      if sizes.length == 2
        a = self.avatar.dup
        a << '?width='
        a << sizes[0]
        a << '&height='
        a << sizes[1]
        a
      else
        self.avatar
      end
    elsif local_avatar_exists?
      self.local_avatar.asset.url(style)
    else
      Asset.new(:asset_type => Asset::TYPE[:user_avatar]).asset.url(style)
    end
  end


  # create a random string for this user that will 
  # be used for the filename for the avatar
  def generate_avatar_file_name
    if self.avatar_file_name.blank?
      self.avatar_file_name = SecureRandom.urlsafe_base64
    end
  end


  def self.no_admins
    where("role != ?", ROLES[:admin])
  end

	# if no role is supplied, default to the basic user role
	def check_for_role
		self.role = ROLES[:user] if self.role.nil?
	end

  # use role inheritence
  # - a role with a larger number can do everything that smaller numbers can do
  def role?(base_role)
    if base_role && ROLES.values.index(base_role)
      return base_role <= self.role
    end
    return false
  end
  
  def role_name
    name = ''
    index = ROLES.values.index(self.role)
    if index.present?
      name = ROLES.keys[index].to_s 
    end
    return name
  end
  
  def nickname
    read_attribute(:nickname).present? ? read_attribute(:nickname) : self.email.split('@')[0]
  end
  
  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(  nickname: auth.info.nickname,
                           provider: auth.provider,
                           uid: auth.uid,
                           email: auth.info.email.present? ? auth.info.email : 'temp@temp.com',
                           avatar: auth.info.image,
                           password: Devise.friendly_token[0,20]
                           )
    end
    user
  end

  # if login fails with omniauth, sessions values are populated with
  # any data that is returned from omniauth
  # this helps load them into the new user registration url
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end
  
	# if user logged in with omniauth, password is not required
	def password_required?
		super && provider.blank?
	end
  
  
end
