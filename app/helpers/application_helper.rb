module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title.html_safe }
  end

  def body_id(body_id)
    content_for(:body_id) { body_id.html_safe }
  end

	def flash_translation(level)
    case level
    when :notice then "alert-info"
    when :success then "alert-success"
    when :error then "alert-danger"
    when :alert then "alert-danger"
    end
  end

	# from http://www.kensodev.com/2012/03/06/better-simple_format-for-rails-3-x-projects/
	# same as simple_format except it does not wrap all text in p tags
	def simple_format_no_tags(text, html_options = {}, options = {})
		text = '' if text.nil?
		text = smart_truncate(text, options[:truncate]) if options[:truncate].present?
		text = sanitize(text) unless options[:sanitize] == false
		text = text.to_str
		text.gsub!(/\r\n?/, "\n")                    # \r\n and \r -> \n
#		text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') # 1 newline   -> br
		text.html_safe
	end

  def current_url
    "#{request.protocol}#{request.host_with_port}#{request.fullpath}"
  end
  
	def full_url(path)
		"#{request.protocol}#{request.host_with_port}#{path}"
	end
  
 def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class=>"btn btn-sm btn-danger")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = "<div class='fields clear'>"
    fields << f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    fields << '</div>'
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class=>"btn btn-sm btn-success")
  end

	# put the default locale first and then sort the remaining locales
	def create_sorted_locales
    x = I18n.available_locales.dup
    
    # sort
    x.sort!{|x,y| x <=> y}

    # move default locale to first position
    default = x.index{|x| x == I18n.default_locale}
    if default.present? && default > 0
      x.unshift(x[default])
      x.delete_at(default+1)
    end

    return x
	end
	
  # apply the strip_tags helper and also convert nbsp to a ' '
	def strip_tags_nbsp(text)
    if text.present?
	    strip_tags(text.gsub('&nbsp;', ' '))
    end
	end

  # get the story type name from the @story_types global variable
  def get_story_type_name(id)
    if @story_types.present?
      index = @story_types.index{|x| x.id == id}
      @story_types[index].name if index.present?
    end
  end
	

	# put the default locale first and then sort the remaining locales
	def create_sorted_translation_objects(trans)
	  if trans.present?
      # sort
      trans.sort!{|x,y| x.locale <=> y.locale}

      # move default locale to first position
      default = trans.index{|x| x.locale == I18n.default_locale.to_s}
      if default.present? && default > 0
        trans.unshift(trans[default])
        trans.delete_at(default+1)
      end
	  end
    return trans
	end

  # Attribute codes:
  # 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
  # Text color codes:
  # 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
  # Background color codes:
  # 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
  def log(msg)    
    Rails.logger.debug("\033[44;37m#{'*'*80}\n    #{DateTime.now.strftime('%d/%m/%Y %H:%M')}#{msg.to_s.rjust(56)}\n#{'*'*80}\033[0;37m")
  end

#devise mappings
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end


#devise mappings end


	# Based on https://gist.github.com/1182136
  class BootstrapLinkRenderer < ::WillPaginate::ActionView::LinkRenderer
    protected

    def html_container(html)
      tag :div, tag(:ul, html,:class=>"pagination"), container_attributes
    end

    def page_number(page)            
        tag :li, link(page, page, :rel => rel_value(page), :"data-filter"=>page ), :class => ('active' if page == current_page)
    end

    def gap
      tag :li, link(super, '#'), :class => 'disabled'
    end

    def previous_or_next_page(page, text, classname)
      tag :li, link(text, page || '#', :"data-filter"=>page ), :class => [classname[0..3], classname, ('disabled' unless page)].join(' ')
    end
  end

  def page_navigation_links(pages)
    #pages = [{1},{1},{1},{1},{1},{1},{1},{1}]
    #Rails.logger.debug("----------------------------------------------------#{pages.class}")
    will_paginate(pages, :class => 'pagination-wrapper', :inner_window => 2, :outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label => '&larr;'.html_safe, :next_label => '&rarr;'.html_safe)
  end
end


module WillPaginate
  module ViewHelpers
    # This class does the heavy lifting of actually building the pagination
    # links. It is used by +will_paginate+ helper internally.
    class LinkRendererBase

      # * +collection+ is a WillPaginate::Collection instance or any other object
      #   that conforms to that API
      # * +options+ are forwarded from +will_paginate+ view helper
      def prepare(collection, options)
        @collection = collection
        @options    = options

        # reset values in case we're re-using this instance
        @total_pages = nil
      end
      
      def pagination
        items = @options[:page_links] ? windowed_page_numbers : []
        items.unshift :previous_page
        items.push :next_page
      end

    protected
    
      # Calculates visible page numbers using the <tt>:inner_window</tt> and
      # <tt>:outer_window</tt> options.
      def windowed_page_numbers
        inner_window, outer_window = @options[:inner_window].to_i, @options[:outer_window].to_i
        window_from = current_page - inner_window
        window_to = current_page + inner_window
        
        # adjust lower or upper limit if other is out of bounds
        if window_to > total_pages
          window_from -= window_to - total_pages
          window_to = total_pages
        end
        if window_from < 1
          window_to += 1 - window_from
          window_from = 1
          window_to = total_pages if window_to > total_pages
        end
        
        # these are always visible
        middle = window_from..window_to

        # left window
        if outer_window + 3 < middle.first # there's a gap
          left = (1..(outer_window + 1)).to_a
          left << :gap
        else # runs into visible pages
          left = 1...middle.first
        end

        # right window
        if total_pages - outer_window - 2 > middle.last # again, gap
          right = ((total_pages - outer_window)..total_pages).to_a
          right.unshift :gap
        else # runs into visible pages
          right = (middle.last + 1)..total_pages
        end
        
        left.to_a + middle.to_a + right.to_a
      end

    private

      def current_page
        @collection.current_page
      end

      def total_pages
        #Rails.logger.debug("111-------------------------------------------#{@collection.inspect}")
        @total_pages ||= @collection.total_pages
      end
    end
  end
end


module ActiveModel
  class Errors
    # Redefine the ActiveModel::Errors::full_messages method:
    #  Returns all the full error messages in an array. 'Base' messages are handled as usual.
    #  Non-base messages are prefixed with the attribute name as usual UNLESS 
    # (1) they begin with '^' in which case the attribute name is omitted.
    #     E.g. validates_acceptance_of :accepted_terms, :message => '^Please accept the terms of service'
    # (2) the message is a proc, in which case the proc is invoked on the model object.
    #     E.g. validates_presence_of :assessment_answer_option_id, 
    #     :message => Proc.new { |aa| "#{aa.label} (#{aa.group_label}) is required" }
    #     which gives an error message like:
    #     Rate (Accuracy) is required
    def full_messages(activerecord_attribute_by_hand=true)
      full_messages = []      
      each do |attribute, messages|
        messages = Array.wrap(messages)
        next if messages.empty?

        if attribute == :base
          messages.each {|m| full_messages << m }
        else
          attr_name = attribute.to_s.gsub('.', '_').humanize
          attr_name = @base.class.human_attribute_name(attribute, :default => attr_name)
          if activerecord_attribute_by_hand
            attr_name = I18n.t('activerecord.attributes.' + attribute.to_s, :default => attr_name)
          end
          options = { :default => "%{attribute} %{message}", :attribute => attr_name }

          messages.each do |m|
            if m =~ /^\^/
              options[:default] = "%{message}"
              full_messages << I18n.t(:"errors.dynamic_format", options.merge(:message => m[1..-1]))
            elsif m.is_a? Proc
              options[:default] = "%{message}"
              full_messages << I18n.t(:"errors.dynamic_format", options.merge(:message => m.call(@base)))
            else
              full_messages << I18n.t(:"errors.format", options.merge(:message => m))
            end            
          end
        end
      end

      full_messages
    end
  end
end