$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rubyplex'
require 'yaml'
require 'liquid'
require 'logger'
require "media_rename/version"
require "media_rename/media"
require "media_rename/utils"
require "media_rename/renamers/plex_renamer"
require "media_rename/movie_template"
require "media_rename/show_template"

module MediaRename

  USER_CONFIG    = File.expand_path("~/.media_rename.yml")
  DEFAULT_CONFIG = File.join(File.dirname(__FILE__), "../config/media_rename.yml")
  SETTINGS ||= begin
    default_config = YAML.load(File.open(DEFAULT_CONFIG).read)
    custom_config  = File.exist?(USER_CONFIG) ? YAML.load(File.open(USER_CONFIG).read) : {}
    default_config.merge(custom_config)
  end

  extend self

  def logger
    @logger ||= begin
      logger = Logger.new(STDOUT)
      logger.formatter = proc do |severity, datetime, progname, msg|
        "#{msg}\n"
      end
      logger
    end
  end

  def load_plex(options = {})
    plex_options = options.slice(:host, :port, :token)
    Plex.server(Plex.config.merge(plex_options))
  end


  class InvalidFileError < StandardError; end

  class LibraryNotFoundError < StandardError; end
end
