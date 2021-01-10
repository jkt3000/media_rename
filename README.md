# MediaRename

A CLI tool that will help rename your media file to a user-specified format, using data from your Plex DB.

Your Plex DB data is used to determine what movie/show a particular file is associated to, so that  you can rename that file into a particular format.

The CLI tool will scan the <path> for any media files and subfolders. The tool will determine the Plex library associated with the given <path>, and use that library. For each media file, it will check the Plex library for the media entry associated with that file. If it finds the Plex media, it will then determine the new name and path of the media file, using the template format provided in the config file.

It will rename and move the file to the new location. It will also look for certain subfolders (such as Delete Scenes, Featurettes, ...) and subtitle files and move those to the new location as well.

For each subfolder in the <path>, it will recurse each subfolder and find any media files, and check those against the plex db. Any media files that match a Plex entry will also get renamed.

## Usage

### Create a media_rename.yml config file and save in home directory

Create a ```/~.media_rename.yml``` configuration file, where you specify the Plex server host, port and token. As well, you define a liquid-based template for a Movie or Show.

### Run CLI tool

```
Usage:
  media_rename plex <path>

Options:
      [--preview], [--no-preview]  # Dry run - don't actually make changes
      [--host=HOST]                # Plex Server host/ip address (use https://x.x.x.x for https or ip address for http)
      [--port=PORT]                # Plex Server port
      [--token=TOKEN]              # Plex token
  v, [--verbose], [--no-verbose]   # Verbose
  t, [--target-path=TARGET_PATH]   # Target path
  c, [--confirm], [--no-confirm]   # Require Confirmation
                                   # Default: true

                                  
Examples:

  ./bin/media_rename plex /Volumes/Media/downloads -t /volume1/Media/

```
