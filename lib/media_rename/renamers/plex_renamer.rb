module MediaRename

  class PlexRenamer 

    attr_reader :library, :options, :target_path, :settings
    attr_accessor :path

    DEFAULT_OPTIONS = { 
      preview: true 
    }.freeze


    # options => :preview, :verbose, :host, :port, :token, :target_path, :confirmation_required
    def initialize(path, options = {})
      @path = path.to_s
      sanitize_options(options)
      set_log_level
      @library = plex_library_from_path(@path)
      # set library based on path
      # 
      # @options     = DEFAULT_OPTIONS.merge(options)
      # @path        = File.expand_path(path)
      # @target_path = @options.fetch(:target_path, root_path)
      # @library     = load_library(options)
      log.info("Using library [#{library.title}]")
      # log.debug("Checking files in path #{path} against Plex Library [#{library.title}]\n Options: #{options} ")
    end

    def rename
      files = MediaRename::Utils.media_files(path)
      files.each do |file|
        rename_file(file)
      end

      folders = MediaRename::Utils.folders(path)
      folders.each do |folder|
        rename_folder(folder)
      end
    end

    def rename_file(file)
      # get plexentry for file
      # return if no plexfile

    end

    def rename_folder(folder)
    end

    # return Plex::Movie | Plex::Show for given file    
    def plexmedia_for_file(file)
    end
    
    # def run(options = {})
    #   # process each subfolder in main path
    #   MediaRename::Utils.folders(path).each {|path| process_path(path)}

    #   # process each file in main path
    #   MediaRename::Utils.files(path).each {|file| process_file(file)}
    # end

    # def rename(path)
    #   # find plex entry for media files
    #   MediaRename::Utils.files(path).each do |file|
    #     if plex_media = @library.find_by_filename(file)
    #       target = target_name(plex_media)
    #       p "curr: #{file}"
    #       p "====> #{target}"

    #       if file == target 
    #         puts "NO change. Skip."
    #         next
    #       end
          
    #       MediaRename::Utils.mv(file, target, options)
    #       old_dir = File.dirname(file)
    #       new_dir = File.dirname(target)
    #       if old_dir != new_dir
    #         MediaRename::Utils.mv_subtitles(old_dir, target, options)
    #         MediaRename::Utils.mv_subfolders(old_dir, target, options)
    #       end
    #     else
    #       puts "[Error] #{file} not found in Plex"
    #     end
    #   end
    #   if MediaRename::Utils.empty?(path)
    #     puts "old path is empty - removing"
    #     MediaRename::Utils.rm_path(path, options)
    #   end
    #   puts
    # end

    # def process_path(path)
    #   log.info("\n---------------------------\n")
    #   log.info("Processing Path: #{path}")
      
    #   entries = find_plex_medias(path)
    #   if entries.empty?
    #     log.debug("No Plex Media matching filename found. Skip.")
    #     return
    #   end
    #   log.debug("PRocessing entries: #{entries}")

    #   process_entries(entries)
    #   MediaRename::Utils.rm_path(path, options)
    # end

    # def process_file(file)
    #   log.debug("Processing File: #{file}")
    #   return unless MediaRename::Utils.media_file?(file)
    #   return unless media = @library.find_by_filename(file)
    
    #   process_entries([{file: file, media: media}])
    # end


    # def process_entries(entries)
    #   entries.each do |entry|
    #     file  = entry[:file]
    #     media = entry[:media]
    #     log.info("Match: [#{library.movie_library? ? media.parent.title : "%s S%d E%d" % [media.parent.show_title, media.parent.season, media.parent.episode] }] for #{File.basename(file)}")
    #     create_entry(file, media)
    #   end
    # end

    # def find_plex_medias(path)
    #   MediaRename::Utils.media_files(path).map do |file| 
    #     next unless media = @library.find_by_filename(file)
    #     {file: file, media: media}
    #   end.compact
    # end
    
    # def create_entry(file, plex_media)
    #   curr_file = file
    #   curr_path = File.dirname(curr_file)
    #   new_file  = target_name(plex_media)
    #   MediaRename::Utils.mv(curr_file, new_file, options)
    #   MediaRename::Utils.mv_subtitles(curr_path, new_file, options)
    #   MediaRename::Utils.mv_subfolders(curr_path, new_file, options) 
    #   log.info("Done [#{new_file}]")
    # end

    # def target_name(plex_media)
    #   templateKlass = library.movie_library? ? MediaRename::MovieTemplate : MediaRename::ShowTemplate 
    #   File.join(target_path, templateKlass.new(plex_media).render)
    # end


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

    def sanitize_options(options)
      @settings = MediaRename::SETTINGS
      @options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
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

    # def root_path
    #   File.expand_path(File.join(path, "../"))
    # end

    # def load_library(options)
    #   library = if plex_id = options.fetch(:plex_library, nil)
    #     Plex.server.library(plex_id)
    #   else
    #     Plex.server.library_by_path(@path)
    #   end
    #   raise MediaRename::LibraryNotFound unless library
    #   library
    # end

    def log
      @log ||= MediaRename.logger
    end

  end
end
