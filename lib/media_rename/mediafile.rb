module MediaRename

  require 'streamio-ffmpeg'
  require 'ostruct'

  class Mediafile

    include FileParser

    attr_reader :type, :filename, :ext, :exists, :directory,
                :title, :year, 
                :tv_season, :tv_episode, 
                :video_format, :video_codec, :audio_codec, :tags

    def initialize(filename)
      @filename   = File.expand_path(filename)
      @file       = sanitize_filename(filename)
      @ext        = File.extname(@filename).gsub(/\./,'')
      @type       = get_file_type(@filename)
      if video?
        @title      = extract_title(@file)
        @year       = extract_year(@file)
        @tags       = extract_tags(@file)
        @tv_season  = extract_season(@file)
        @tv_episode = extract_episode(@file)
        extract_media_info
      end
    end

    def video?
      VIDEO_EXT.include?(ext)
    end

    def exists?
      File.exist?(filename)
    end

    def directory?
      File.directory?(filename)
    end

    def attributes
      data = {
        type: type,
        filename: filename,
        ext: ext,
        exists: exists?,
        directory: directory?
      }
      
      data.merge!(video_attributes) if video?
    end

    def to_liquid
      attributes.stringify_keys
    end

    def duration
      mediainfo.duration
    end


    private

    def video_attributes
      {
        title: title,
        year: year,
        tv_season: tv_season,
        tv_episode: tv_episode,
        video_format: video_format,
        video_codec: video_codec,
        audio_codec: audio_codec,
        duration: duration,
        tags: tags
      }
    end

    def extract_media_info
      @video_format ||= MediaRename::Utils.video_format(mediainfo.width, mediainfo.height)
      @video_codec  ||= MediaRename::Utils.video_codec(mediainfo.video_codec)
      @audio_codec  ||= MediaRename::Utils.audio_codec(mediainfo.audio_codec, mediainfo.audio_channels)
    end

    def mediainfo
      @mediainfo ||= (exists? && video?) ? FFMPEG::Movie.new(filename) : OpenStruct.new
    end
  end

end