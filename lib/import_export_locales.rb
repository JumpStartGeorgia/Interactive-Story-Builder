##### taken from https://github.com/atomicobject/annotranslate

require 'yaml'
require 'csv'
require 'rake'

module ImportExportLocales

  class TranslationsExporter

    def self.export(file_prefix, export_to=nil)
      exporter = self.new(file_prefix, export_to)
      exporter.export_translations
    end

    def initialize(file_prefix, export_to=nil)
      # Format pertinent paths for files
      here = File.expand_path(File.dirname(__FILE__))
      config = File.expand_path(File.join(here, "..", "config"))
      @locales_folder = File.join(config, "locales")
      @base_locale = I18n.default_locale.to_s
      @base_yml_file = File.join(@locales_folder, "#{@base_locale}.yml")
      @prefix = file_prefix
      @translations_support = File.join(config, "translations")
#      FileUtils.mkpath(@translations_support)
      @duplicates_file = File.join(@translations_support, "#{@prefix}_shared_strings.yml")
      @export_folder = export_to ? export_to : File.join(@translations_support, "export")      
#      @cache = YAML.load_file(@duplicates_file)

      FileUtils.rm_f Dir["#{@export_folder}/*.csv"]

      # Create supported foreign languages collection
      @available_locales = I18n.available_locales.map{|x| x.to_s}
      # remove the base_locale
      @available_locales.delete(@base_locale)
      @foreign_languages = []
      @available_locales.each do |code|
        source_yml = File.join(@locales_folder, "#{code}.yml")
        dest_csv = File.join(@export_folder, "#{@prefix}.#{code}.csv")
        @foreign_languages << {code: code, yml: source_yml, csv: dest_csv}
      end
    end

    def export_translations
      # Load English strings first to use as golden copy of all translatable strings/keys
      load_english_strings

      # Generate CSV export files for each foreign language
      @foreign_languages.each do |lang|
        puts "Exporting #{lang[:code]} translations"
        puts "  from:  #{lang[:yml]}" if File.exist? lang[:yml]
        puts "  using: #{@base_yml_file}"
        puts "  to:    #{lang[:csv]}"

        # Export keys/translations to the proper CSV file
        CSV.open(lang[:csv], "wb", encoding: 'UTF-8') do |csv|
          csv << ["Line #", "Key", "#{@base_locale} Version", "#{lang[:code]} Translation"]
          index = 0
          load_translations(lang).each do |id, translation|
            csv << [index+1, id, @english[index].last, translation]
            index += 1
          end
        end
      end
    end

    private

    def load_english_strings
      @cache = {}
      new_hash = YAML.load_file(@base_yml_file)
      @english = hash_to_pairs(new_hash, @cache)
      linked_keys = @cache.values.select{|r| r.count > 1}

      # Create empty translations template with keys from English
      @valid_ids = []
      @template = []
      @english.each do |id, string|
        @valid_ids << replace_id_locale(id)
        @template << [id, '']
      end

      # Report duplicated strings for sharing translations
      if !linked_keys.empty?
        puts "#{linked_keys.count} duplicate strings found! (see #{@duplicates_file} for details)"
      else
        puts "No duplicate strings detected"
      end
      File.open(@duplicates_file, "wb") do |cf|
        cf.print YAML.dump(linked_keys)
      end
      puts "Found a total of #{@english.count} translatable strings"
      puts @valid_ids.map{|y| "#{y}\n"}
    end

    def load_translations(config)
      # Create from template
      translations = @template.dup.map{|id, translation| [replace_id_locale(id, config[:code]), translation]}

      # Merge in existing translations, if they exist
      if File.exist? config[:yml]
        hash_to_pairs(YAML.load_file(config[:yml])).each do |id, translation|
          found_at = @valid_ids.index(replace_id_locale(id))
          raise "Invalid translation ID '#{id}' found in #{config[:yml]}" unless found_at
          translations[found_at] = [id, translation]
        end
      end

      translations
    end

    private

    def replace_id_locale(id, replacement='')
      replacement += '.' if !replacement.empty? && !replacement !~ /\.$/
      id.dup.sub(/^[a-z]{2,2}-?[A-Z]{0,2}\./, replacement)
    end

    def hash_to_pairs(h, cache={}, prefix=nil)
      h.flat_map do |k,v|
        k = "#{prefix}.#{k}" if prefix
        case v
        when Hash
          hash_to_pairs v, cache, k
        else
          cache[v] ||= []
          cache[v] << k
          [[k,v]]

          # Even if string is repeated we still need to get it so ignore this
          # if cache[v].count > 1
          #   # The string content has already been tracked; let's just make a note in the cache
          #   # that this key also refers to the current string.
          #   #puts "#{v.inspect} is referred to by multiple keys: #{cache[v].join(" ")}"
          #   []
          # else
          #   [[k,v]]
          # end
        end
      end
    end

  end

  class TranslationsImporter
    include Rake::DSL

    def self.import(file_prefix, import_from=nil)
      importer = self.new(file_prefix, import_from)
      importer.import_translations
    end

    def initialize(file_prefix, import_from=nil)
      # Format pertinent paths for files
      here = File.expand_path(File.dirname(__FILE__))
      config = File.expand_path(File.join(here, "..", "config"))
      @translations_support = File.join(config, "translations")
      @import_folder = import_from ? import_from : File.join(@translations_support, "import")
      @locales_folder = File.join(config, "locales")
      @base_locale = I18n.default_locale.to_s
      @base_file = File.join(@locales_folder, "#{@base_locale}.yml")
      @base_yml_file = YAML.load_file(@base_file)
      @prefix = file_prefix
      @duplicates_file = File.join(@translations_support, "#{@prefix}_shared_strings.yml")

      load_base_ids
      # @cache = YAML.load_file(@duplicates_file)

      # Create supported foreign languages collection
      @available_locales = I18n.available_locales.map{|x| x.to_s}
      # remove the base_locale
      @available_locales.delete(@base_locale)

      @foreign_languages = Dir[File.join(@import_folder, "*#{@prefix}*.csv")].map do |csv|
        m = csv.match(/\.([a-z]{2,2}-?[A-Z]{0,2})\.csv$/)
        raise "Failed parsing language code from #{csv}" if m.nil?
        lang_code = m[1]
        raise "Parsed language code '#{lang_code}' is not supported" if !@available_locales.include?(lang_code)
        dest_yml = File.join(@locales_folder, "#{lang_code}.yml")
        source_csv = File.join(@import_folder, "#{@prefix}.#{lang_code}.csv")
        untranslated_strings_report = File.join(@import_folder, "#{@prefix}.missing.#{lang_code}.txt")
        {
          code: lang_code,
          name: lang_code,
          yml: dest_yml,
          csv: source_csv,
          missing_translations: [],
          untranslated_report: untranslated_strings_report,
        }
      end
    end

    def import_translations
      raise "No CSV files to import\nimport folder: #{@import_folder}\n\n" if @foreign_languages.empty?
      missing_translations = 0
      @foreign_languages.each do |lang|
        puts "Importing #{lang[:code]} translations"
        puts "  from: #{lang[:csv]}"
        puts "  to:   #{lang[:yml]}"
        csv_to_yml(lang)
        not_translated = lang[:missing_translations].count
        puts "  WARNING: #{not_translated} untranslated strings found!" if not_translated > 0
        missing_translations += not_translated
      end
      puts "\n#{missing_translations} untranslated strings\nImport complete"
    end

    private

    def load_base_ids
      @valid_ids = {}
      hash_to_ids(@base_yml_file.dup)
    end

    def hash_to_ids(h, prefix=nil)
      h.each do |k,v|
        k = "#{prefix}.#{k}" if prefix
        case v
        when Hash
          hash_to_ids v, k
        else
          common_key = replace_id_locale(k)
          @valid_ids[common_key] = v
        end
      end
    end

    def replace_id_locale(id, replacement='')
      replacement += '.' if !replacement.empty? && !replacement !~ /\.$/
      id.dup.sub(/^[a-zA-Z_-]+\./, replacement)
    end

    def csv_to_yml(config)
      load_translations(config).tap do |translations|
        result = translate_it(config, @base_yml_file.dup, translations, '')
        File.open(config[:yml], "wb") do |cf|
          cf.print YAML.dump(result)
        end

        # Report untranslated strings
        FileUtils.rm_f config[:untranslated_report]
        if !config[:missing_translations].empty?
          File.open(config[:untranslated_report], "wb", encoding: 'UTF-8') do |report|
            report.puts "Untranslated String ID"
            report.puts "======================"
            config[:missing_translations].each{|id| report.puts id}
          end
          puts "  Missing translations report: #{config[:untranslated_report]}"
        end
      end
    end

    def load_translations(config)
      {}.tap do |translations|
        CSV.foreach(config[:csv], headers: true, encoding: 'UTF-8') do |row|
          id = row[1] # id = row["Key"]
          translation = row[3] # translation = row["Translated Version"]
          raise "Invalid translation ID found: #{id} - #{translation}" if @valid_ids[replace_id_locale(id)].nil?
          translations[id] = translation
        end

        # # Populate keys for duplicated strings with common translation
        # @cache.each do |keys|
        #   primary_key = keys.first
        #   foreign_key = replace_id_locale(primary_key, config[:code])
        #   raise "Whoa! No value for #{primary_key}" unless translations.has_key?(foreign_key)
        #   keys.select{|k| k != primary_key}.each do |dup_key|
        #     dup_key = replace_id_locale(dup_key, config[:code])
        #     translations[dup_key] = translations[foreign_key]
        #   end
        # end
      end
    end

    def translate_it(config, input, translations, base_key)
      input.keys.each do |key|

        value = input[key]
        if base_key && !base_key.empty?
          full_key = "#{base_key}.#{key}"
        else
          full_key = key
        end

        case value
        when Hash
          translate_it(config, value, translations, full_key)
        else
          foreign_key = replace_id_locale(full_key, config[:code])
          translation = translations[foreign_key]
          if !translation || translation.empty?
            config[:missing_translations] << foreign_key
          end
          input[key] = translation
        end

      end

      input
    end

  end

end