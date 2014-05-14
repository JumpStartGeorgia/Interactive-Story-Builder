module FormtasticBootstrap
  module Inputs
    module Base
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
    end
  end
end
