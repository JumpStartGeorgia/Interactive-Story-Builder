class User < ActiveRecord::Base

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
                  :about, :default_story_locale, :permalink, :local_avatar_attributes

  has_permalink :create_permalink

  validates :role, :presence => true

  ROLES = {:user => 0, :staff_pick => 50, :admin => 99}

  def create_permalink
    self.nickname.clone
  end

  def has_provider_avatar?
    self.provider.present? && self.avatar.present?
  end
  
  def local_avatar_exists?
    self.local_avatar.present? && self.local_avatar.asset.exists?
  end

  def avatar_url(style = :'28x28')
    if has_provider_avatar? && !local_avatar_exists?
      self.avatar
    elsif local_avatar_exists?
      self.local_avatar.asset.url(style)
    else
      Asset.new(:asset_type => Asset::TYPE[:user_avatar]).asset.url(style)
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
    ROLES.keys[ROLES.values.index(self.role)].to_s
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
