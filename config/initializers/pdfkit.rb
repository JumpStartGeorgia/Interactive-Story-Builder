# if you need to generate pdfs, uncomment the following
=begin
PDFKit.configure do |config|
	config.wkhtmltopdf = Rails.root.join('vendor', 'bin', 'wkhtmltopdf-amd64').to_s if Rails.env.production? || Rails.env.staging?
	config.default_options = { page_size: 'A4', print_media_type: true }
end
=end
