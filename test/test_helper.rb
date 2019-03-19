$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'media_renamer'

require 'minitest/autorun'
require 'active_support/test_case'
require 'mocha/mini_test'


#ActiveSupport::TestCase.test_order = :random

class ActiveSupport::TestCase

  FILE_PATH = File.expand_path('./../files', __FILE__)

 # test_order = :random

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

end

