module MediaRename

  require 'fileutils'
  module Utils

    DELETEABLE_PATH = "/_deleteable"

    MAX_FILES = 5

    extend self

    # given a width and height, returns back video format
    # 8k      7680x4320
    # 4k      4096x
    # 2k      2048x
    # 1080p   1920x1080
    # 720p    1280x720
    # 480p    640x480
    # 360p    480x360
    def video_format(width, height)
      return unless width && width
      if width >= 7600 || height >= 4300
        "8K"
      elsif width >= 3800 || height > 2100
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
    end

    # hevc, h264, mpeg4, msmpeg4, vc1
    def video_codec(codec)
      case codec
      when "h264"
        'H264'
      when "mpeg4"
        'MP4'
      when 'hevc', 'h265'
        "HEVC"
      else
        nil
      end
    end

    # "aac", "ac3", "dca", "mp3", "truehd", "wmav2"
    def audio_codec(codec, channels = nil)
      text = case codec
        when 'aac', 'ac3', 'mp3', 'dca'
          codec.upcase
        else
          'OTH'
        end
      channels ? "#{text} #{channels}ch" : text
    end


    # move file from source => dest (rename file)
    def move_file(source, dest, options)
      return if source == dest
      dest_path = File.dirname(dest)
      if confirmation("mv \"#{File.basename(source)}\"\n=> \"#{dest}\"", options)
        if !File.directory?(dest_path)
          FileUtils.mkdir_p dest_path, verbose: true, noop: options[:preview]
        end
        FileUtils.mv source, dest, verbose: true, noop: options[:preview]
      end
    end

    def delete_dir(file, options)
      return unless File.exist?(file)
      dir_files = Dir.entries(file).reject {|x| x.start_with?('.')}
      if dir_files.count > 0
        log.debug "Path [#{file}] contains #{dir_files.count} files...skipping"
        return
      end
      if confirmation("rmdir #{file}", options)
        FileUtils.rm_rf file, verbose: true,noop: options[:preview]
      end
    end

    def delete_file(file, options)
      return unless File.exist?(file) 
      if options[:delete_files]
        if confirmation("rm #{file}", options)
          FileUtils.rm_f file, verbose: true, noop: options[:preview]
        end
      else
        move_file(file, deleteable_file(file, options), options)
      end
    end

    def deleteable_file(file, options)
      path = file.split(options[:orig_path])
      File.join(options[:orig_path], DELETEABLE_PATH, path)
    end


    def rename_file(mediafile, filename, params)
      query_type  = params[:tv] ? :find_tv : :find_movie
      render_type = params[:tv] ? :render_tv : :render_movie
      results     = MediaRename::TMDB.method(query_type).call(mediafile.title)
      chosen_file = nil
      chosen      = false

      while !chosen do
        if results.count == 0
          results = manual_lookup(query_type) 
        end
        target_files = results.map {|show| MediaRename::Templates.method(render_type).call(show, mediafile, params) }
        
        case selected = display_and_select_selections(target_files)
        when 0
          # skip all together
          chosen = true
          chosen_file = nil
        when 1..5
          # pick one of the options
          if selected > (target_files.count + 1)
            puts "Invalid option. Try again."
          else
            chosen_file = target_files[selected-1]
            chosen = true
          end
        else
          # none of the above - do manual lookup
          results = []
        end
      end

      if chosen_file
        MediaRename::Utils.move_file(filename, chosen_file, params)
      else
        puts "No valid result found. Skipping."
      end
    end


    private

    def display_and_select_selections(files)
      files = files.slice(0, MAX_FILES)
      files.to_enum.with_index(1) do |filename, index|
        puts "[#{index}] #{File.basename(filename)}"
      end
      if files.length == 1
        puts "Pick: [return] for default, [n]one of the above, [s]kip: "
      else
        puts "Pick: 1-#{files.length}, [n]one of the above, [s]kip: "
      end

      value = STDIN.getch
      case value
      when '1','2','3','4','5'
        value.to_i
      when "\r", "\n"
        1
      when "n", "N"
        log.debug "None of the above. Manual lookup."
        nil
      else
        log.debug "None chosen. Skipping."
        0
      end      
    end

    # allow user to manually enter new tv/movie name
    def manual_lookup(query_type)
      puts "Enter movie/tv name, eg: Star Wars"
      video_name = STDIN.gets.chomp
      return [] if video_name.blank?
      MediaRename::TMDB.method(query_type).call(video_name)
    end

    def confirmation(msg, options)
      return true unless options[:confirmation_required] == true
      puts "> #{msg}?\nCONFIRM? [Y/n/q]"
      value = STDIN.getch
      case value
      when 'q', "Q", "\u0003"
        puts
        abort("Quitting...")
      when 'y', "Y", "\r", "\n"
        puts
        true
      else
        log.debug "Skipping."
        false
      end
    end



    def log
      MediaRename.logger
    end

  end

end