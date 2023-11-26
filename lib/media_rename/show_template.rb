module MediaRename

  class ShowTemplate < MovieTemplate

    # record => episode
    def initialize(record:, media:, part:, file:)
      @template   = Liquid::Template.parse(SETTINGS['TV_TEMPLATE'], error_mode: :strict)
      @media      = media
      video_codec = []
      video_codec << MediaRename::Media.video_format(media.width, media.height, media.video_codec)
      #video_codec += MediaRename::Media.tags(media)

      mediainfo = MediaInfo.get_info(file)

      # find atmos tag
      atmos = false
      ddplus = false
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

      video_codec.compact!
      @attributes = {
        title: record.show_title.to_s.gsub(':', '-'),
        year: (record.year rescue ''),
        video_format: MediaRename::Media.video_format(media.width, media.height, media.video_codec),
        video_codec: video_codec,
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels, atmos, ddplus),
        tags: "",
        part: part,
        ext: media.container,
        tv_season: record.season,
        tv_episode: record.episode
      }
    end
  end

end
