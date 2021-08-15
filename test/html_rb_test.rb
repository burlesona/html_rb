require 'test_helper'

describe HtmlRB do
  include HtmlRB

  it "should exist" do
    assert HtmlRB.is_a?(Module)
  end

  it "should do stuff with Tag directly" do
    t = HtmlRB::Tag.new :p
    assert_equal "<p></p>", t.to_s
    t = HtmlRB::Tag.new :p, "test"
    assert_equal "<p>test</p>", t.to_s
    t = HtmlRB::Tag.new :ol do
      li "one"
      li "two"
      li "three"
    end
    assert_equal "<ol><li>one</li><li>two</li><li>three</li></ol>", t.to_s
    t = HtmlRB::Tag.new :ol do
      li { span "one" }
      li { span "two" }
      li { span "three" }
    end
    assert_equal "<ol><li><span>one</span></li><li><span>two</span></li><li><span>three</span></li></ol>", t.to_s
  end

  it "should generate HTML tags with a !DOCTYPE" do
    assert_equal "<!DOCTYPE html><html></html>", html(document: true)
  end

  it "should generate HTML tags with something inside via block" do
    assert_equal "<!DOCTYPE html><html>something</html>", html(document: true){ text "something" }
  end

  it "should generate HTML tags with attributes and content via block" do
    out = html(document: true, lang: "en") do
      text "something"
    end
    assert_equal %Q|<!DOCTYPE html><html lang="en">something</html>|, out
  end

  it "should be cool with variables from outside the closure" do
    mytext = "hello world"
    out = html do
      p mytext, class: "awesome"
    end
    assert_equal %Q|<p class="awesome">hello world</p>|, out
  end

  it "should generate p tags" do
    out = html do
      p
    end
    assert_equal "<p></p>", out
  end

  it "should generate p tags with attributes" do
    out = html do
      p class: "awesome"
    end
    assert_equal %Q|<p class="awesome"></p>|, out
  end

  it "should ignore nil attributes" do
    out = html do
      p id: nil
    end
    assert_equal "<p></p>", out
  end

  it "should sub underscore symbol args to dashes" do
    out = html do
      p data_foo: "bar"
    end
    assert_equal %Q|<p data-foo="bar"></p>|, out
  end

  it "should let you do custom things if you use string keys" do
    out = html do
      p "_my_Attribute" => "foo"
    end
    assert_equal %Q|<p _my_Attribute="foo"></p>|, out
  end

  it "should generate html tags with content" do
    out = html do
      p "Hello", id: "foo"
    end
    assert_equal %Q|<p id="foo">Hello</p>|, out
  end

  it "should nest tags" do
    out = html do
      p class: "super" do
        span "Hello!"
      end
    end
    assert_equal %Q|<p class="super"><span>Hello!</span></p>|, out
  end

  it "should do everything using the HtmlRB.html method instead" do
    out = HtmlRB.html do
      p class: "super" do
        span "Hello!"
      end
    end
    assert_equal %Q|<p class="super"><span>Hello!</span></p>|, out
  end

  it "should not close self closing tags" do
    out = html do
      img src: "foo.jpg"
    end
    assert_equal %Q|<img src="foo.jpg">|, out
  end

  it "should generate boolean attributes" do
    out = html do
      option "Test", value:"test", selected: true
    end
    assert_equal %Q|<option value="test" selected>Test</option>|, out
  end

  it "should not leave whitespace on false boolean attributes" do
    out = html do
      option "Test", value:"test", selected: false
    end
    assert_equal %Q|<option value="test">Test</option>|, out
  end

  it "should accept strings" do
    foo = html do
      p "This is a foo"
    end
    foobaz = html do
      text foo
      p "This is a baz"
    end

    assert_equal %Q|<p>This is a foo</p><p>This is a baz</p>|, foobaz
  end

  it "should accept strings with `render` too" do
    foo = html do
      p "This is a foo"
    end
    foobaz = html do
      render foo
      p "This is a baz"
    end

    assert_equal %Q|<p>This is a foo</p><p>This is a baz</p>|, foobaz
  end

  it "should accept custom elements using #tag" do
    out = html do
      tag 'my-element', class: 'test' do
        p 'Test content'
      end
    end
    assert_equal %Q|<my-element class="test"><p>Test content</p></my-element>|, out
  end

  it "should allow registering a new standard element and using it in the DSL" do
    t = HtmlRB::Tag.new
    refute t.respond_to?(:my_element)

    HtmlRB::Tag.register('my-element')
    out = html do
      my_element class: 'test' do
        p 'Test content'
      end
    end
    assert_equal %Q|<my-element class="test"><p>Test content</p></my-element>|, out

    HtmlRB::Tag.remove_method :my_element
  end

  it "should allow registering a new void element and using it in the DSL" do
    t = HtmlRB::Tag.new
    refute t.respond_to?(:my_element)

    HtmlRB::Tag.register('my-element', void: true)
    out = html do
      my_element class: 'test'
      p 'Test content'
    end
    assert_equal %Q|<my-element class="test"><p>Test content</p>|, out

    HtmlRB::Tag.remove_method :my_element
  end

  it "should work with ruby logic" do
    user_name = nil
    logged_in = false
    links = %w(home login signup)

    out = html do
      if logged_in
        p "Hello #{user_name}"
      else
        p "Lost? Try one of these links:"
        ol do
          links.each do |link|
            li do
              a link.upcase, href: "/#{link}"
            end
          end
        end
      end
    end

    correct = %Q|<p>Lost? Try one of these links:</p><ol><li><a href="/home">HOME</a></li><li><a href="/login">LOGIN</a></li><li><a href="/signup">SIGNUP</a></li></ol>|

    assert_equal correct, out
  end
end
