module MediaRename
  class MovieTemplate
    attr_reader :template, :media, :record, :part, :file, :options

    def initialize(record:, media:, part:, file:, options: {})
      @template = Liquid::Template.parse(SETTINGS['MOVIE_TEMPLATE'], error_mode: :strict)
      @media    = media
      @record   = record
      @part     = part
      @file     = file
      @options  = options
    end

    def render
      params = attributes.transform_keys(&:to_s)
      template.render(params)
    end


    private


    def attributes
      video_codec = build_video_codec
      {
        title: record.title.to_s.gsub(':', '-'),
        edition: record.to_hash.key?("editionTitle") ? record.editionTitle : "",
        year: record.year,
        parts_count: media.parts.count,
        part: part,
        video_format: MediaRename::Media.video_format(media.width, media.height),
        video_codec: video_codec,
        audio_codec: MediaRename::Media.audio_codec(media.audio_codec, media.audio_channels, atmos?, ddplus?),
        ext: media.container
      }
    end

    def build_video_codec
      video_codec = []
      video_codec << MediaRename::Media.video_format(media.width, media.height, media.video_codec)
      video_codec += MediaRename::Media.tags(media)
      video_codec << "DV" if dolby_vision?
      video_codec << "HDR" if hdr?
      video_codec.uniq.compact
    end

    def atmos?
      stream = media.parts.first.hash["Stream"]
      stream && stream.any? {|x| x['title'] && x['title'].include?("Atmos") } ||
      audio_tracks.any? { |track| track["format_commercial_if_any"] && track["format_commercial_if_any"].include?("Atmos") }
    end

    def ddplus?
      audio_tracks.any? { |track| track["format_commercial_if_any"] && track["format_commercial_if_any"].include?("Dolby Digital Plus") }
    end

    def dolby_vision?
      video_tracks.any? { |track| track["hdr_format"] && track["hdr_format"].include?("Dolby Vision") }
    end

    def hdr?
      video_tracks.any? { |track| track["transfer_characteristics"] && track["transfer_characteristics"].include?("PQ") }
    end

    def audio_tracks
      return [] unless mediainfo["media"] && mediainfo["media"]["track"]
      mediainfo["media"]["track"].select { |track| track["type"] == "Audio" }
    end

    def video_tracks
      return [] unless mediainfo["media"] && mediainfo["media"]["track"]
      mediainfo["media"]["track"].select { |track| track["type"] == "Video" }
    end

    def mediainfo
      @mediainfo ||= MediaInfo.get_info(file, @options)
    end
  end
end
