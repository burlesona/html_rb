module HtmlRB
  VERSION = "1.0.0".freeze
  Error = Class.new(StandardError)
end

require 'html_rb/constants'
require 'html_rb/tag'

module HtmlRB
  def html(content=nil,document:false,doctype:"html",**attrs,&block)
    name = nil
    dt = ""
    if document
      name = :html
      dt = "<!DOCTYPE #{doctype}>" if doctype
    end
    dt + Tag.new(name, content, **attrs, &block).to_s
  end

  alias_method :markup, :html
  module_function :markup
end
