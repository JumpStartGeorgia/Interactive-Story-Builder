class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
	# :registerable, :recoverable,
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role

  validates :role, :presence => true

  def self.no_admins
    where("role != ?", ROLES[:admin])
  end

	# if no role is supplied, default to the basic user role
	def check_for_role
		self.role = ROLES[:user] if self.role.nil?
	end

  # use role inheritence
  # - a role with a larger number can do everything that smaller numbers can do
  ROLES = {:user => 0, :admin => 99}
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
    self.email.split('@')[0]
  end

end
