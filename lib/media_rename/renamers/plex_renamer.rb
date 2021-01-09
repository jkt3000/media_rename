module MediaRename

  class PlexRenamer 

    attr_reader :path, :library, :options, :target_path, :settings

    # options => :preview, :verbose, :host, :port, :token, :target_path, :confirm
    def initialize(path, options = {})
      @path = path.to_s
      sanitize_options(options)
      set_log_level
      @library = plex_library_from_path(@path)
      log.info("Using library [#{library.title}]")
    end


    # works for root path has root media files, but what about 
    # specifying path that has key subfolders?
    def rename_files
      files = MediaRename::Utils.media_files(path)
      log.debug("Found #{files.count} files in path #{path}")
      log.debug("RENAMING MEDIA FILES") unless files.empty?
      files.each do |file| 
        log.debug("\n")
        target_file = target_filename(file)
        rename_file(file, target_file)
      end

      folders = MediaRename::Utils.folders(path)
      log.debug("Found #{folders.count} subfolders in path #{path}")
      log.debug("RENAMING SUBFOLDERS") unless folders.empty?
      folders.each {|folder| rename_path(folder) }
    end

    def rename_file(source, target_file = nil)
      log.debug("Rename: Could not find file in Plex..skip") && return if target_file.nil?
      log.debug("Rename: Src and dest are same..skip [#{source} v #{target_file}]") && return if source == target_file
      log.debug("Rename: Renaming => [#{target_file}]")
      MediaRename::Utils.mkdir(File.dirname(target_file), options)
      MediaRename::Utils.mv(source, target_file, options)
      MediaRename::Utils.mv_subtitles(path, target_file, options)
    end

    def rename_path(path)
      log.debug("\n")
      log.debug("Renaming path [#{path}]")
      target_file = nil
      MediaRename::Utils.media_files(path).each do |file|
        next unless target_file = target_filename(file)
        log.debug("Found media file #{file}...renaming")
        rename_file(file, target_file)
      end
      MediaRename::Utils.mv_subfolders(path, target_file, options)
      MediaRename::Utils.rm_path(path, options) if MediaRename::Utils.empty?(path)
    end
    
    def target_filename(file)
      plexrecord = library.find_by_filename(file)
      log.debug("No plex record found for [#{file}]") && return unless plexrecord
      plexmedia = plexrecord.find_by_filename(file)
      templateKlass = library.movie_library? ? MediaRename::MovieTemplate : MediaRename::ShowTemplate 
      File.join(target_path, templateKlass.new({record: plexrecord, media: plexmedia}).render)
    end


    private


    def plex_library_from_path(path)
      @library ||= begin
        server = MediaRename.load_plex(plex_options)
        library = server.library_by_path(path)
        raise MediaRename::LibraryNotFoundError if library.nil?
        library
      end
    end

    def plex_options
      dlft_plex_options = {
        host: settings.fetch("PLEX_HOST", nil),
        port: settings.fetch("PLEX_PORT", nil),
        token: settings.fetch("PLEX_TOKEN", nil)
      }
      dlft_plex_options.merge(options.slice(:host, :port, :token))
    end

    def confirm?
      !!options[:confirm]
    end

    def verbose?
      options.fetch(:verbose, false)
    end

    def target_path
      options.fetch(:target_path, "")
    end

    def sanitize_options(options)
      @settings = MediaRename::SETTINGS
      @options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      log.debug("Options: #{options}")
    end

    def set_log_level
      MediaRename.logger.level = verbose? ? :debug : :info
      log.info("Verbose logging") if verbose?
    end

    def confirmation(msg = "Continue", options = @options)
      return true unless confirm?
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
        puts "No - skip"
        false
      end
    end
    
    def log
      @log ||= MediaRename.logger
    end

  end
end
