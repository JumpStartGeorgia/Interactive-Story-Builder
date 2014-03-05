if Rails.env.production? || Rails.env.staging?
	ActionMailer::Base.smtp_settings = {
		:address              => "smtp.gmail.com",
		:port                 => 587,
		:domain               => 'www.jumpstart.ge',
		:user_name            => ENV['APPLICATION_FEEDBACK_FROM_EMAIL'],
		:password             => ENV['APPLICATION_FEEDBACK_FROM_PWD'],
		:authentication       => 'plain',
		:enable_starttls_auto => true
	}
end
