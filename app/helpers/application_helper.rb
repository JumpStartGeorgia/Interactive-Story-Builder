module ApplicationHelper

  def title(page_title)
    content_for(:title) { page_title.html_safe }
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
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", :class=>"btn btn-small btn-danger")
  end
  
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = "<div class='fields clear'>"
    fields << f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    fields << '</div>'
    link_to_function(name, "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")", :class=>"btn btn-small btn-success")
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
    will_paginate(pages, :class => 'pagination-wrapper', :inner_window => 2, :outer_window => 0, :renderer => BootstrapLinkRenderer, :previous_label => '&larr;'.html_safe, :next_label => '&rarr;'.html_safe)
  end
end


