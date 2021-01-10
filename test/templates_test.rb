require 'test_helper'

class TemplatesTest < ActiveSupport::TestCase

  def setup
    stub_request(:get, Plex.server.query_path("/library/sections")).to_return(status: 200, body: load_response(:libraries))
    stub_request(:get, Plex.server.query_path("/library/sections/1/all")).to_return(status: 200, body: load_response(:movies))
    stub_request(:get, Plex.server.query_path("/library/sections/2/all")).to_return(status: 200, body: load_response(:shows))
    stub_request(:get, Plex.server.query_path("/library/metadata/10401/allLeaves")).to_return(status: 200, body: load_response(:show1))
        
    @lib_path = "/volume1/Media/Movies"
    @renamer = MediaRename::PlexRenamer.new(@lib_path, preview: true, target_path: '/Volumes/Media')    

    @show_path = "/volume1/Media/TV"
    @show_renamer = MediaRename::PlexRenamer.new(@show_path, preview: true, target_path: '/Volumes/Media')
  end

  # movie

  test "create a movie template" do
    @movie    = @renamer.library.all.first
    @media    = @movie.medias.first
    @template = MediaRename::MovieTemplate.new(record:  @movie, media: @media)

    assert @template.is_a?(MediaRename::MovieTemplate)
    assert_equal "2 Guns", @template.attributes[:title]
    assert_equal "mp4", @template.attributes[:ext]
  end

  test "render generates new filename for media file" do
    @movie    = @renamer.library.all.first
    @media    = @movie.medias.first
    @template = MediaRename::MovieTemplate.new(record: @movie, media: @media)

    file = "/Movies/2 Guns (2013)/2 Guns (2013) [1080p] [AAC 2.0].mp4"
    assert_equal file, @template.render
  end

  # show

  test "render generates new filename for show template" do
    @show     = @show_renamer.library.all.first
    @episode  = @show.episodes.first
    @media    = @episode.medias.first
    @template = MediaRename::ShowTemplate.new(record: @episode, media: @media)
    
    file = "/TV/Band of Brothers/Band of Brothers S01/Band of Brothers S01E01 [1080p].mp4"
    assert_equal file, @template.render
  end

end
