require File.dirname(__FILE__) + '/lib/magic_search'

require 'mongoid'
Mongoid::Components.send(:include ,MagicSearch::Search)