module MediaRename

  require 'fileutils'

  module Utils

    MEDIA_FILES    = %w| .mp4 .mov .mkv .avi |
    SUB_FILES      = %w| .srt .idx .sub |
    MIN_MEDIA_SIZE = 838860800 # 800.megabytes
    SUBDIRECTORIES = %w| subs subtitles featurettes | # case insensitive

    extend self


    # return array of all media files in a given path
    def detect_media_files(path)
      _, files = Dir.glob(escape_glob("#{path}/*")).partition {|e| Dir.exist?(e) }
      files.select do |f| 
        MEDIA_FILES.include?(File.extname(f)) && File.size?(f) > MIN_MEDIA_SIZE
      end
    end

    def detect_subtitle_files(path)
      _, files = Dir.glob(escape_glob("#{path}/*")).partition {|e| Dir.exist?(e) }
      files.select {|f| SUB_FILES.include?(File.extname(f)) }
    end

    def mkdir(path, options = {})
      FileUtils.mkdir_p path, verbose: true, noop: options[:preview]
    end

    def mv_subtitles(source, dest, options = {})
    end
    
    def mv(source, dest, options = {})
      log.debug("moving file to #{dest}")
      mkdir(File.dirname(dest), options)
      FileUtils.mv source, dest, verbose: true, noop: options[:preview]
    end

    def rm_parent(source, options = {})
      path = File.dirname(source)
      log.debug("deleting directory #{path}")
      FileUtils.rm_rf path, verbose: true, noop: options[:preview] 
    end

    def escape_glob(s)
      s.gsub(/[\[\]\{\}]/) {|x| "\\" + x }
    end


    private


    def log
      @log ||= MediaRename.logger
    end

  end
end