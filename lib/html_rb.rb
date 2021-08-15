module HtmlRB
  VERSION = "2.0.0".freeze
  Error = Class.new(StandardError)
end

require 'html_rb/constants'
require 'html_rb/tag'

module HtmlRB
  module_function def html(content=nil, document: false, **attrs, &block)
    if document
      "<!DOCTYPE html>" + Tag.new('html', content, **attrs, &block).to_s
    else
      Tag.new(nil, content, **attrs, &block).to_s
    end
  end
end
