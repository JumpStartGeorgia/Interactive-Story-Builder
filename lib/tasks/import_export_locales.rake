require 'yaml'
require 'csv'
require 'i18n'
require 'fileutils'
require 'import_export_locales'

namespace :translations do

  file_prefix = "twweb"
  here = File.expand_path(File.dirname(__FILE__))
  root = File.expand_path(File.join(here, "..", ".."))
  config_folder = File.join(root, "config")
  directory(import_folder = File.join(config_folder, "translations", "import"))
  directory(export_folder = File.join(config_folder, "translations", "export"))
  I18n.load_path << Dir[File.join('config', 'locales', '*.yml')]

  desc "Import CSVs from #{import_folder.sub(/^#{root}/,'')}"
  task :import => [import_folder] do
    ImportExportLocales::TranslationsImporter.import(file_prefix, import_folder)
  end

  desc "Export CSVs to #{export_folder.sub(/^#{root}/,'')}"
  task :export => [export_folder] do
    ImportExportLocales::TranslationsExporter.export(file_prefix, export_folder)
  end

end

# Internationalization tasks
namespace :i18n do

  desc "Validates YAML locale bundles"
  task :validate_yml => [:environment] do |t, args|

    # Grab all the yaml bundles in config/locales
    bundles = Dir.glob(File.join(RAILS_ROOT, 'config', 'locales', '**', '*.yml'))

    # Attempt to load each bundle
    bundles.each do |bundle|
      begin
        YAML.load_file( bundle )
      rescue Exception => exc
        puts "Error loading: #{bundle}"
        puts exc.to_s
      end
    end
  end
end
