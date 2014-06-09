module FormtasticBootstrap
  #overwriting value of default class for error group
  class FormBuilder < Formtastic::FormBuilder
    configure :default_inline_error_class, 'error-inline'
    configure :default_block_error_class,  'error-block'    
  end

  module Inputs
    module Base
      # HINTS
      module Hints
        
        include Formtastic::Inputs::Base::Hints

        def hint_html(inline_or_block = :inline)
          if hint?
            hint_class = if inline_or_block == :inline
              options[:hint_class] || builder.default_inline_hint_class
            else
              options[:hint_class] || builder.default_block_hint_class
            end
            template.content_tag(
              :div, 
              template.content_tag(:div, "?"), 
              :class => hint_class,
              :title => Formtastic::Util.html_safe(hint_text)
            )
          end
        end
      end
      # ERRORS
      module Errors

        include Formtastic::Inputs::Base::Errors

        def error_html(inline_or_block = :inline)
          errors? ? send(:"error_#{builder.inline_errors}_html", inline_or_block) : ""
        end

        def error_sentence_html(inline_or_block)
          error_class = if inline_or_block == :inline
            options[:error_class] || builder.default_inline_error_class
          else
            options[:error_class] || builder.default_block_error_class
          end          
          template.content_tag(
              :div, 
              template.content_tag(:div, "!"), 
              :class => error_class,
              :title => Formtastic::Util.html_safe(errors.to_sentence.html_safe)
            )
        end

        def error_list_html(ignore)
          super()
          # error_class = options[:error_class] || builder.default_error_list_class
          # list_elements = []
          # errors.each do |error|
          #   list_elements << template.content_tag(:li, Formtastic::Util.html_safe(error.html_safe))
          # end
          # template.content_tag(:ul, Formtastic::Util.html_safe(list_elements.join("\n")), :class => error_class)
        end

        def error_first_html(inline_or_block = :inline)
          error_class = if inline_or_block == :inline
            options[:error_class] || builder.default_inline_error_class
          else
            options[:error_class] || builder.default_block_error_class
          end          
          template.content_tag(
              :div, 
              template.content_tag(:div, "!"), 
              :class => error_class,
              :title => Formtastic::Util.html_safe(errors.first.untaint)
          )
        end

        def error_none_html(ignore)
          # super
          ""
        end

      end
      # LABELLING
      module Labelling

        include Formtastic::Inputs::Base::Labelling

        def label_html_options
          super.tap do |options|
            # Bootstrap defines class 'label' too, so remove the
            # one that gets created by Formtastic.
            options[:class] = options[:class].reject { |c| c == 'label' }
            options[:class] << " control-label"
          end
        end

        # def control_label_html
        def label_html(hints = nil, errors = nil )
          embed = ""
          if(hints.present?) 
            embed << hints
          end
          if(errors.present?)
           embed << errors
          end
          Rails.logger.debug(embed)
          render_label? ? builder.label(input_name, label_text << embed.html_safe , label_html_options) : "".html_safe
        end

      end  

      # WRAPPING
     module Wrapping

          include Formtastic::Inputs::Base::Wrapping

          def bootstrap_wrapping(&block)
            form_group_wrapping do
              label_html(hint_html, error_html(:block)) <<
              template.content_tag(:span, :class => 'form-wrapper') do
                input_content(&block)                         
              end
            end
          end

          def input_content(&block)
            content = [
              add_on_content(options[:prepend]),
              options[:prepend_content],
              yield,
              add_on_content(options[:append]),
              options[:append_content]
            ].compact.join("\n").html_safe

            if prepended_or_appended?(options)
              template.content_tag(:div, content, :class => add_on_wrapper_classes(options).join(" "))
            else
              content
            end
          end

          def prepended_or_appended?(options)
            options[:prepend] || options[:prepend_content] || options[:append] || options[:append_content]
          end

          def add_on_content(content)
            return nil unless content
            template.content_tag(:span, content, :class => 'input-group-addon')
          end

          def form_group_wrapping(&block)
            template.content_tag(:div,
              template.capture(&block).html_safe,
              wrapper_html_options
            )
          end

          def wrapper_html_options
            super.tap do |options|
              options[:class] << " form-group"
              options[:class] << " has-error" if errors?
            end
          end

          def add_on_wrapper_classes(options)
            [:prepend, :append, :prepend_content, :append_content].find do |key|
              options.has_key?(key)
            end ? ['input-group'] : []
          end

        end
    end
  end


    # BooleanInput
    module Inputs
    class BooleanInput < Formtastic::Inputs::BooleanInput
      include Base

      def to_html
        checkbox_wrapping do
          hidden_field_html <<
          "".html_safe <<
          label_with_nested_checkbox.html_safe
        end
      end

      def hidden_field_html
        template.hidden_field_tag(input_html_options[:name], unchecked_value, :id => nil, :disabled => input_html_options[:disabled] )
      end

      def label_with_nested_checkbox
        builder.label(
          method,
          label_text_with_embedded_checkbox << hint_html,
          label_html_options
        )
      end

      def checkbox_wrapping(&block)
        template.content_tag(:div,
          template.capture(&block).html_safe,
          wrapper_html_options
        )
      end

      def wrapper_html_options
        super.tap do |options|
          options[:class] = (options[:class].split - ["form-group"] + ["checkbox"]).join(" ")
        end
      end

    end
  end
end
