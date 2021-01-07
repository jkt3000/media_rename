$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'media_rename'
#require "minitest/autorun"
#require 'webmock/minitest'
require 'active_support'
require 'active_support/test_case'
require 'active_support/testing/autorun'

require 'mocha/minitest'


FILE_PATH = File.expand_path('./../files', __FILE__)


def load_file(file)
  File.join(FILE_PATH, file)
end

def mock_mediainfo(params)
  orig_params = {
    width: 1920, 
    height: 1080, 
    video_codec: 'h264', 
    audio_codec: "aac", 
    audio_channels: 2,
    duration: 100
  }
  obj = mock()
  obj.stubs(orig_params.merge(params))
  FFMPEG::Movie.stubs(:new).returns(obj)
end

