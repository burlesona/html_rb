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

  it "should generate HTML tags with no !DOCTYPE" do
    assert_equal "<html></html>", html(document: true, doctype: false)
  end

  it "should generate HTML tags with custom !DOCTYPE" do
    d = %Q|HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"|
    correct = "<!DOCTYPE #{d}><html></html>"
    assert_equal correct , html(document: true, doctype: d)
  end

  it "should generate HTML tags with something inside via argument" do
    assert_equal "<html>something</html>", html("something", document: true, doctype:false)
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

  it "should let you do weird things if you start the key with a bang" do
    out = html do
      p :"!someWierd_stuffs" => "foo"
    end
    assert_equal %Q|<p someWierd_stuffs="foo"></p>|, out
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

  it "should do everything using the HTML.markup method instead" do
    out = HtmlRB.markup do
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

  it "should be composable" do
    foo = html do
      p "This is a foo"
    end
    foobaz = html do
      raw foo
      p "This is a baz"
    end

    assert_equal %Q|<p>This is a foo</p><p>This is a baz</p>|, foobaz
  end
end
