# HtmlRB

In a nutshell, this library makes it very easy to generate idiomatic HTML from idiomatic Ruby.

```ruby
html do
  div class: 'container' do
    p "Hello, world!"
  end
end
```
...becomes...

```html
<div class="container"><p>Hello, world!</p></div>
```

## Installation

In your gemfile;

```ruby
gem 'html_rb'
```

or on the command line:

```bash
gem install html_rb
```

and when you want to use it

```ruby
require 'html_rb'
```

## How To

It's super easy, and I think the tests are pretty self-explanatory, but here are the basics.

You make HTML by starting a block. You can do this one of two ways:

(1) Usually you'll want to include HtmlRB in some context where you plan to make a generate a
bunch of HTML in Ruby.

```ruby
include HtmlRB
html do
  # html goes here
end
```
Note that `#html` is the only method that gets included into your namespace, so there's not
a lot of pollution to worry about.

(2) If you don't want to use the `#html` method, you can just call it directly on the module:

```ruby
HtmlRB.html do
  # markup goes here
end
```

Under the hood, both of those are doing the same thing, using an `HtmlRB::Tag` instance
to collect and build HTML and return it as a string. If you didn't use the DSL it would look
like this:

```ruby
tag = HtmlRB::Tag.new(:p,"I'm awesome content",class:"awesome")
tag.to_s #=> <p class="awesome">I'm awesome content</p>
```

## Basic Usage

Technically HtmlRB is providing a DSL, but the goal is to match HTML 1:1, so there's very little
to learn.

Within any `html` block there's a method for every valid HTML tagname. Each tag method accepts
three optional arguments: content, attributes, and a block.

There are only three rules you really need to know:

1. You can give a content string OR a block, not both.
2. If you want to insert a text node, you can use the `text` method.
3. If you _don't_ call one of the html methods, the line will be ignored.

Here's what it looks like in use. This Ruby...

```ruby
html do
  div class: 'top' do
    p "First paragraph"
    span "This is a span"
  end
  ol id: "my-list" do
    li "First item"
    li "Second item"
    li "Third item"
  end
  a "Click here", href: "github.com"
end
```

...generates this HTML:

```html
<div class="top">
  <p>First paragraph</p>
  <span>This is a span</span>
</div>
<ol class="list">
  <li>First item</li>
  <li>Second item</li>
  <li>Third item</li>
</ol>
<a href="github.com">Click here</a>
```
\*_Note that in this and all following examples the HTML output is 'prettified' for
readability, but the actual output from HtmlRB is 'minified', ie. compacted into
a single line string with no whitespace between elements._

## HTML Attributes

HtmlRB does all the transformations that you'd expect to allow you to type things in
natural-looking ruby while generating well-formed HTML.

```ruby
html do
  img src:"awesome.gif"
  button "Can't click here", disabled: true
end
```

```html
<img src="awesome.gif">
<button disabled>Can't click here</button>
```

It will also convert underscores to dashes so you can `data-*` attributes (and all attributes)
in a more normal way:

```ruby
html { span "Yo!", data_yo: "yo" }
```

```html
<span data-yo="yo">Yo!</span>
```

### Custom elements

If you'd like to make a custom element you can do so by using the `tag` method, like so:

```ruby
html do
  tag "my-element" do
    p "Content inside custom element."
  end
end
```

```html
<my-element>
  <p>Content inside custom element.
</my-element>
```

If you want to use this a lot and want to add a method for it, you can do so via `HtmlRB::Tag.register`.

```ruby
HtmlRB::Tag.register('my-element')
```
If your custom element is self-closing (a void element, like `img`), then you need to pass the
`void` option on registration:

```ruby
HtmlRB::Tag.register('my-void', void: true)
```

After registration your new element will be available in the DSL, downcased and with dashes turned to
underscores for Ruby syntax compatibility.

```ruby
html do
  my_element id: 'my-id' do
    p 'Inside a custom element'
  end
  my_void id: 'my-id-2'
end
```

```html
<my-element id="my-id">
  <p>Inside a custom element</p>
</my-element>
<my-void id="my-id-2">
```

### Custom Attributes

If you want to create a custom HTML attribute using underscores, or don't want HtmlRB to
'standardize' the attribute key for you, use a string key instead of a symbol and the value
will be used as-is.

```ruby
html do
  span "Some text", "_my_Attribute" => "myValue" }
end
```

```html
<span _my_Attribute="myValue">Some text</span>
```


## Logic and composition

Technically the `text` method can be used to capture any string, not just
text nodes. Since this is a little surprising, there's a less surprising alias
that you can use instead: `render.` It works like this:

```ruby
my_heading = html do
  h1 "I'm a big title!"
end

html do
  render my_heading
  p "I'm a bunch of paragraph text."
end
```

That will generate:

```html
<h1>I'm a big title!</h1>
<p>I'm a bunch of paragraph text.</p>
```

Because HtmlRB only captures content when its DSL methods are called, any other
Ruby expression will be ignored. This means you can use conditional logic or other
control flow as you would expect.

```ruby
user_name = nil
logged_in = false
links = %w(home login signup)

my_html = html do
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
```
This returns the following:
```html
<p>Lost? Try one of these links:</p>
<ol>
  <li><a href="/home">HOME</a></li>
  <li><a href="/login">LOGIN</a></li>
  <li><a href="/signup">SIGNUP</a></li>
</ol>

```

## Documents

The `html` has one more feature that the `Tag` class does not. In addition
to generating HTML fragments, it will prepend the HTML doctype if you pass
the `document: true` option.

1) Typical use.

```ruby
html do
  p "Hello World"
end
```

```html
<p>Hello World</p>
```

2) With `document: true`.

```ruby
html document:true do
  p "Hello World"
end
```

```html
<!DOCTYPE html>
<html>
  <p>Hello World</p>
</html>
```

## Why call it HtmlRB?

I really wanted to just call this HTML, but somebody's got that name already. I thought about rhtml, but
somebody's got that too. It's nuts, OK? As far as the capitalization, well, I tried all the permutations
and picked the one I thought sucked the least.

## That's it!

If you like this, awesome. Tell your friends.

If you don't like this, awesome. Keep it to yourself :)

If you find a bug, send me a pull request with a fix and a test that proves it.

## License

MIT. Have fun.

©2016 Andrew Burleson
