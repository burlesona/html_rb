module HtmlRB
  class Tag
    def initialize(name=nil,content=nil,**attrs,&block)
      @strings = []
      build name, content, **attrs, &block
    end

    def to_s
      @strings.join
    end

    private
    def build(name=nil,content=nil,**attrs,&block)
      void = HtmlRB::VOID_ELEMENTS.include?(name)
      raise HtmlRB::Error, "May not provide both content and block" if content && block_given?
      raise HtmlRB::Error, "Void elements cannot enclose content" if void && (content || block_given?)

      @strings << "<#{[name,attribute_string(attrs)].join(" ").strip}>" if name
      unless void
        @strings << content if content
        instance_eval(&block) if block_given?
        @strings << "</#{name}>" if name
      end
    end

    def raw(html_component)
      @strings << html_component
    end

    # Define all the tag methods
    (HtmlRB::STD_ELEMENTS + HtmlRB::VOID_ELEMENTS).each do |el|
      define_method(el) do |content=nil,**attrs,&block|
        build el, content, **attrs, &block
      end
    end

    # Used for Text Nodes
    def text(content)
      build nil, content
    end

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
      str = k.to_s
      if str.start_with? "!"
        str.slice!(0)
      else
        str.gsub!("_","-")
      end
      str
    end
  end
end
