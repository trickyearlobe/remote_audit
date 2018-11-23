# frozen_string_literal: true

require 'chefspec'
require 'chefspec/berkshelf'

# Library classes defined in this cookbook
require_relative '../libraries/guid_manager'
require_relative '../libraries/exception_manager'

RSpec.configure do |c|
  c.formatter = 'doc'
  c.expect_with :rspec do |e|
    # Stop rspec whining about coulda shoulda woulda
    e.syntax = [:expect, :should]
  end
end
