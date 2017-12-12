$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require_relative '../lib/ruby_coincheck_client'
require 'webmock'

include WebMock::API
WebMock.enable!
