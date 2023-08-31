module MediaRename

  module Media
    
    extend self

    # given a width and height, returns back video format
    # 8k      7680x4320
    # 4k      4096x
    # 2k      2048x
    # 1080p   1920x1080
    # 720p    1280x720
    # 480p    640x480
    # 360p    480x360
    def video_format(width, height, codec = nil)
      return unless width && width
      text = if width >= 7600 || height >= 4300
        "8K"
      elsif width >= 3800 || height >= 2100
        "4K"
      elsif width >= 1900 || height >= 1000
        "1080p"
      elsif width >= 1200 || height >= 700
        "720p"
      elsif width >= 640 || height >= 480
        "480p"
      elsif width >= 480 || height >= 360
        "360p"
      else
        "SD"
      end
      value = video_codec(codec)
      [text, value].compact.join(" ")
    end

    # hevc, h264, mpeg4, msmpeg4, vc1
    def video_codec(codec)
      codec = codec.to_s.downcase
      case codec
      when "h264"
        'H264'
      when "mpeg4", "mp4"
        'MP4'
      when 'hevc', 'h265'
        nil
      when 'av1'
        "AV1"
      else
        nil
      end
    end

    # "aac", "ac3", "dca", "mp3", "truehd", "wmav2"
    def audio_codec(codec, channels = nil, atmos = false)
      text = case codec.downcase
        when 'aac', 'ac3', 'mp3', 'eac3'
          codec.upcase
        when 'dca', 'dts'
          'DTS'
        when 'truehd'
          'TRUEHD'
        when 'dca-ma'
          'DTS-HD'
        when 'opus'
          'OPUS'
        else
          'OTH'
        end
      chan = case channels
      when 3
        '2.1'
      when 6
        '5.1'
      when 7
        '6.1'
      when 8
        '7.1'
      when nil
        nil
      else
        "#{channels}.0"
      end
      [text, chan, (atmos ? "ATMOS" : nil)].compact.join(" ")
    end
    
    def tags(media)
      entries = []
      # if aspect_ratio = 1.78 and filename contains IMAX
      if (media.aspect_ratio.to_f == 1.78) && (media.parts.first.file.include?('IMAX'))
        entries.push("IMAX")
      end

      if (media.parts.first.file.include?('REMUX'))
        entries.push("REMUX") 
      end

      # check for Dolby Vision
      stream = media.parts.first.streams.first
      if (stream.hash.key?("codecID") && stream.hash['codecID'] == 'dvhe') 
        entries.push("DV")
      end
      
      entries
    end



  end

end