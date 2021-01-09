module MediaRename

  require 'fileutils'

  module Utils

    MEDIA_FILES    = %w| .mp4 .mov .mkv .avi .m4v |
    SUB_FILES      = %w| .srt .idx .sub |
    MIN_MEDIA_SIZE = 200000000 #838860800 # 800.megabytes
    KEY_FOLDERS = [
      "subs", "Subtitles", "Extras", "Featurettes",
      "Bonus Disc", "Deleted Scenes"
    ].map(&:downcase)

    extend self


    def files(path)
      ls(path).last
    end

    def folders(path)
      list = ls(path).first
      log("Folders found: [#{list.count}] #{list}")
      list
    end

    def media_files(path)
      list = files(path).select {|file| media_file?(file) }
      log("Media files found: [#{list.count}] #{list}")
      list
    end

    def media_file?(file)
      MEDIA_FILES.include?(File.extname(file).downcase)
    end

    def subtitle_files(path)
      files(path).select {|f| SUB_FILES.include?(File.extname(f).downcase) }
    end

    def key_subfolders(path)
      folders(path).select {|p| KEY_FOLDERS.include?(File.basename(p.downcase)) }
    end

    def mkdir(path, options = {})
      return if File.directory?(path)
      log("Creating directory [#{path}]")
      FileUtils.mkdir_p path, verbose: options[:verbose], noop: options[:preview]
    end

    def mv_subtitles(source, dest, options = {})
      dest_path = File.dirname(dest)
      files = subtitle_files(source)
      log("Found [#{files.count}] subtitle files #{files}")
      files.each do |file|
        dest_file = File.join(dest_path, File.basename(file.gsub(":","-")))
        mv(file, dest_file, options)
      end
    end

    def mv_subfolders(source, dest, options = {})
      dest_path = File.dirname(dest)
      key_subfolders(source).each do |file|
        dest_file = File.join(dest_path, File.basename(file))
        mv(file, dest_file, options)
      end
    end
    
    def mv(source, dest, options = {})
      log("Moving [#{File.basename(source)}] => #{dest}")
      return if source == dest
      mkdir(File.dirname(dest), options)
      FileUtils.mv source, dest, verbose: options[:verbose], noop: options[:preview]
    end

    def rm_path(path, options = {})
      log("Deleting directory [#{path}]")
      FileUtils.rm_rf path, verbose: options[:verbose], noop: options[:preview] 
    end

    def empty?(path)
      Dir.glob(escape_glob("#{path}/*")).empty?
    end


    private


    def ls(path)
      path = File.expand_path(File.directory?(path) ? path : File.dirname(path))
      Dir.glob(escape_glob("#{path}/*")).partition {|e| Dir.exist?(e) }
    end

    def escape_glob(s)
      s.gsub(/[\[\]\{\}]/) {|x| "\\" + x }
    end

    def log(msg)
      logger.debug(msg) 
    end

    def logger
      @logger ||= MediaRename.logger
    end

  end
end