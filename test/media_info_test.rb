require 'test_helper'

class MediaInfoTest < ActiveSupport::TestCase
  test "#get_info returns parsed JSON output from mediainfo command" do
    file_path = '/path/to/media/file.mp4'
    expected_output = {
      "media" => {
        "format" => "MPEG-4",
        "duration" => "01:23:45",
        "bit_rate" => "128 Kbps"
      }
    }

    # Stub the `mediainfo` command to return a JSON string
    MediaInfo.stub(:`, ->(command) { '{"media":{"format":"MPEG-4","duration":"01:23:45","bit_rate":"128 Kbps"}}' }) do
      assert_equal expected_output, MediaInfo.get_info(file_path)
    end
  end
end
