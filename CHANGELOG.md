# Changelog

## 2.0.0

New features:
- Expose a generic `tag` method for custom elements
- Support adding custom elements into the DSL via HtmlRB::Tag.register
- Refactor to handle void elements at load time instead of per-tag invocation
- Allow custom HTML attributes by passing string keys

Breaking changes:
- Drop the use of bangs to mark custom attributes, that was a dumb idea.
- Drop custom doctypes, I don't think this will ever be used,
  and this lib is just making strings. It's trivial to prepend a custom doctype if desired.
- Drop the `HtmlRB::markup` alias.
- Drop `Tag#raw`
- Add `Tag#render` as an alias for `Tag#text`
- Clean up file structure a bit
- Update gems

Comments:

Previously `raw` was doing the exact same thing as `text` - just capturing
a string and appending it to the content of a tag, but was implemented differently,
which was silly. The naming of that also always bothered me.

To tidy this up I dropped the `raw` method, in favor of just using `text` to
capture strings. But since that feels really weird with things that aren't going
to turn into text nodes in the browser, I added an alias, `render`.

So effectively, `raw` is now `render`.

## 1.0.0

- Created the library, used it in some personal projects.