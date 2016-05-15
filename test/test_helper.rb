require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
Minitest::Reporters.use!

# Add Project Lib Dir to Load Path
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__),"..","lib"))

require 'html_rb'
