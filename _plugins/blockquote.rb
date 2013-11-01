# @see https://github.com/josegonzalez/josediazgonzalez.com/blob/master/_plugins/blockquote.rb
# source: https://github.com/zroger/jekyll-plugins/blob/master/blockquote.rb

module Jekyll

  # Outputs a string with a given attribution as a quote
  #
  # {% blockquote John Paul Jones %}
  # Monkeys!
  # {% endblockquote %}
  # ...
  # <blockquote>
  # Monkeys!
  # <br />
  # John Paul Jones
  # </blockquote>
  #
  class Blockquote < Liquid::Block
    Syntax = /([\w\s,]+)/

    def initialize(tag_name, markup, tokens)
      @by = nil
      if markup =~ Syntax
        @by = $1
      end
      super
    end

    def render(context)
      output = super
      if @by.nil?
        '<blockquote>' + output + '</blockquote>'
      else
        '<blockquote>' + output + '<br />' + @by + '</blockquote>'
      end
    end
  end

  # Outputs a string with a given attribution as a pullquote
  #
  # {% blockquote John Paul Jones %}
  # Monkeys!
  # {% endblockquote %}
  # ...
  # <blockquote class="pullquote">
  # Monkeys!
  # <br />
  # John Paul Jones
  # </blockquote>
  #
  class Pullquote < Liquid::Block
    Syntax = /([\w\s]+)/

    def initialize(tag_name, markup, tokens)
      @by = nil
      if markup =~ Syntax
        @by = $1
      end
      super
    end

    def render(context)
      output = super
      if @by.nil?
        '<blockquote class="pullquote">' + output + '</blockquote>'
      else
        '<blockquote class="pullquote">' + output + '<br />' + @by + '</blockquote>'
      end
    end
  end
end

Liquid::Template.register_tag('blockquote', Jekyll::Blockquote)
Liquid::Template.register_tag('pullquote', Jekyll::Pullquote)