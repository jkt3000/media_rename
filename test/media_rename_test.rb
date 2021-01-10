require 'test_helper'

class MediaRenameTest < ActiveSupport::TestCase

  def setup
  end

  
  test "#load_plex overrides existing plex config with passed in options" do
    opts = Plex.config
    
    server = MediaRename.load_plex({host: '10.1.1.1', port:123, token: 'test'})
    assert_not_equal opts[:host], server.host
    assert_not_equal opts[:port], server.port
    assert_not_equal opts[:token], server.token
  end

end
