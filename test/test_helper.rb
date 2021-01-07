$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'media_rename'
require 'active_support'
require 'active_support/test_case'
require 'active_support/testing/autorun'
require 'mocha/minitest'


FILE_PATH = File.expand_path('./../files', __FILE__)


def load_file(file)
  File.join(FILE_PATH, file)
end
