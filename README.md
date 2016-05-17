# HTML for Ruby
aka. HtmlRB

## Why?

1. Because there are a lot of times that I'd like to build some HTML in a ruby file,
whether it's a view object or a form library or some such
2. I'm almost never using Rails, so those tag builders and whatnot aren't around.
3. There are other libs that do this but all the ones I could find were either:
  a. Outdated
  b. Unmaintained
  c. Undocumented
  d. Overcomplicated
  e. Used a syntax I didn't like
  f. Multiple of the above

So, in the tradition of hackers everywhere, I rolled my own.

I'm hoping that what I've made here is the opposite of all the above (simple, maintained, documented, nice),
and that it might catch on a little bit in Ruby world for those reasons. Because goodness knows I've wished
for a while there was a go-to tool for this.

BUT, hey, if it ends up being just me that uses it, I'll still be happy :)

## Why HtmlRB?

I really wanted to just call this HTML, but somebody's got that name already. I thought about rhtml, but
somebody's got that too. It's nuts, OK? As far as the capitalization, well, I tried all the permutations
and picked the one I thought sucked the least.

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

Generally, you'll want to make HTML by starting a block. You can do this one of two ways:

1)

```ruby
HtmlRB.markup do
  # markup goes here
end
```

2)

```ruby
include HtmlRB
html do
  # markup goes here
end
```

(Technically the `markup` method will also be included if you include HtmlRB)

Under the hood, both of those are doing the same thing, using an `HtmlRB::Tag` instance
to collect and build HTML and return it as a string. It looks like this:

```ruby
tag = HtmlRB::Tag.new(:p,"I'm awesome content",class:"awesome")
tag.to_s #=> <p class="awesome">I'm awesome content</p>
```

You can pass a block to any tag and it will be instance eval'd exposing DSL magic.

Within the block there's a method for every valid HTML tagname. Each tag method accepts
three optional arguments: content, attributes, and a block.

- You can nest blocks infinitely deep.
- You can give a content string OR a block, not both.
- If you want to insert a text node, you can use the `text` method.

Here's what it looks like in use. This Ruby...

```ruby
html do
  p "I'm so cool"
  span "I'm cooler", class: "cooler"
  ol class: "coolest" do
    li "I'm the coolest"
    li "let me count"
    li "the ways"
  end
  a "Search!", href: "google.com"
end
```

...generates this HTML:

```html
<p>I'm so cool</p>
<span class="cooler">I'm cooler</span>
<ol class="coolest">
  <li>I'm the coolest</li>
  <li>let me count</li>
  <li>the ways</li>
</ol>
<a href="google.com">Search!</a>
```

But ~~does it blend~~ is it composable? Yes.

```ruby
foo = html do
  p "The foo"
end

html do
  raw foo
  p "The baz"
end
```

...generates:

```html
<p>The foo</p>
<p>The baz</p>
```

Neat, huh?

It'll do all the cool stuff like making self-closing tags and boolean attributes correctly too:

```ruby
html do
  img src:"awesome.gif"
  button "No clicky!", disabled:true
end
```

```html
<img src="awesome.gif">
<button disabled>No clicky!</button>
```

It will also convert underscores to dashes so you can `data-*` attributes (and all attributes, really)
in a more normal way:

```ruby
html { span "Yo!", data_yo: "yo" }
```

```html
<span data-yo="yo">Yo!</span>
```

If for some reason you specifically need underscores, you can put a bang on the front of your symbol key
and it will get used as-is (minus the bang):

```ruby
html { span "I see...", :"!my_CustomNess" => "Flexible!" }
```

```html
<span my_CustomNess="Flexible!">I see...</span>
```

Note that html isn't case-sensitive so, that part isn't really going to do much for you. But if you want
underscores in your attributes then I'm guessing you care a lot about what they look like for aesthetic
reasons, and I get that.


Lastly: the `markup` / `html` method makes a document fragment by default,
but it has one special feature compared to the normal Tag instances:
it can optionally be used to create the root of an HTML document,
in which case it will create the HTML tag and a doctype.

Here are the options:


1) Generate a fragment

```ruby
html do
  p "Hello World"
end
```
```html
<p>Hello World</p>
```

2) Generate a document

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

3) Generate a document with no doctype (I won't ask why)

```ruby
html document:true, doctype: false do
  p "Hello World"
end
```

```html
<html>
  <p>Hello World</p>
</html>
```

4) Generate a document with custom (old school?) doctype

```ruby
html document:true, doctype: %Q|HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"| do
  p "Hello World"
end
```

```html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
  <p>Hello World</p>
</html>
```

## That's it!

If you like this, awesome. Tell your friends.

If you don't like this, awesome. Keep it to yourself :)

If you find a bug, send me a pull request with a fix and a test that proves it.

## License

MIT. Have fun.

©2016 Andrew Burleson
