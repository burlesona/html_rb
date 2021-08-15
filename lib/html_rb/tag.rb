module HtmlRB
  class Tag
    def initialize(name=nil,content=nil,**attrs,&block)
      @strings = []
      tag name, content, **attrs, &block
    end

    def to_s
      @strings.join
    end

    def self.register(tag_name, void: false)
      method_name = tag_name.to_s.downcase.gsub('-','_') # Rubify the tag name.
      define_method(method_name) do |content=nil,**attrs,&block|
        tag tag_name, content, _void: void, **attrs, &block
      end
    end

    def self.unregister(tag_name)
      method_name = tag_name.to_s.downcase.gsub('-','_') # Rubify the tag name.
      remove_method method_name
    end

    # Define all the tag methods
    HtmlRB::STD_ELEMENTS.each {|tag_name| register tag_name }
    HtmlRB::VOID_ELEMENTS.each {|tag_name| register tag_name, void: true }

    private

    def tag(name=nil, content=nil, _void: false, **attrs, &block)
      void = _void
      raise HtmlRB::Error, "May not provide both content and block" if content && block_given?
      raise HtmlRB::Error, "Void elements cannot enclose content" if void && (content || block_given?)

      @strings << "<#{[name,attribute_string(attrs)].join(" ").strip}>" if name
      
      return if void

      @strings << content if content
      instance_eval(&block) if block_given?
      @strings << "</#{name}>" if name
    end

    # Used for Text Nodes
    def text(content)
      tag nil, content
    end

    # Really, text is just appending a string, so we can append anything.
    # But saying `text` before some block of HTML stored in a variable feels
    # wrong, so we'll add an alias `render` which feels less strange.
    alias render text

    # ATTRIBUTE HANDLING
    def attribute_string(hash={})
      hash.delete_if{|k,v| v.nil? || v == "" }
          .map{|k,v| attribute_pair(k,v) }
          .compact
          .join(" ")
    end

    def attribute_pair(k,v)
      if HtmlRB::BOOL_ATTRS.include?(k)
        attribute_key(k) if v
      else
        %Q|#{attribute_key(k)}="#{v}"|
      end
    end

    def attribute_key(k)
      return k if k.is_a?(String)
      
      k.to_s.gsub("_","-")
    end
  end
end
