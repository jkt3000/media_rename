module MediaRename

  class MovieTemplate

    attr_reader :template, :attributes

    def initialize(record:, media:, part:, file:)
      @template   = Liquid::Template.parse(SETTINGS['MOVIE_TEMPLATE'], error_mode: :strict)
      @media      = media
      video_codec = []
      video_codec << MediaRename::Media.video_format(media.width, media.height, media.video_codec)

      mediainfo = MediaInfo.get_info(file)

      # find atmos tag
      ddplus = false
      atmos = media.parts.first.hash["Stream"].any? {|x| x['title'] && x['title'].include?("Atmos") }
      mediainfo["media"]["track"].select do |track|
        track["type"] == "Audio"
      end.each do |track|
        next unless track["format_commercial_if_any"]
        if track["format_commercial_if_any"].include?("Atmos")
          atmos = true
        end
        if track["format_commercial_if_any"].include?("Dolby Digital Plus")
          ddplus = true
        end
      end

      video_codec += MediaRename::Media.tags(media)

      # find dolby vision in mediainfo
      dolby_vision = mediainfo["media"]["track"].select do |track|
        track["type"] == "Video"
      end.any? do |track|
        next unless track["hdr_format"]
        track["hdr_format"].include?("Dolby Vision")
      end
      video_codec << "DV" if dolby_vision

      video_codec.compact!
      @attributes = {
        title: record.title.to_s.gsub(':', '-'),
        edition: record.to_hash.key?("editionTitle") ? record.editionTitle : "",
        year: record.year,
        parts_count: @media.parts.count,
        part: part,
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: video_codec,
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels, atmos, ddplus),
        ext: media.container
      }
      @attributes
    end

    def render
      params = attributes.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo}
      template.render(params)
    end
  end

end
