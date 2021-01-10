$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'media_rename'
require 'active_support'
require 'active_support/test_case'
require 'active_support/testing/autorun'
require 'mocha/minitest'
require 'webmock/minitest'


WebMock.disable_net_connect!

FILE_PATH = File.expand_path('./../files', __FILE__)

def load_file(file)
  File.join(FILE_PATH, file)
end

RESPONSES = {
  libraries: 'libraries.json',
  movies: 'library1.json',
  movies_count: 'library1_count.json',
  movie1: 'movie1.json',
  shows: 'library2.json',
  shows_count: 'library2_count.json',
  show1: 'show1.json',
  show1_details: 'show_details.json'
}
 
def load_response(key)
  file = RESPONSES.fetch(key)
  open("test/fixtures/#{file}").read
end