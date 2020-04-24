# MediaRename

A post-Transmission download script that will rename download files based on 
movie was created in Plex entry. Uses your Plex API to query what the 
downloaded files were named to, and renames and moves files to proper
path based on the Movie Template format you created.

## Usage

Usage:
  media_rename rename_from_plex <path>

Options:
      [--preview], [--no-preview]   # Dry run - don't actually make changes
  p, [--plex-library=PLEX_LIBRARY]  # Plex Library to search against

    ./bin/media_rename rename_from_plex /Volumes/Media/downloads -p Movies --preview



eg:

bin/media_rename rename_from_plex /Volumes/Media/downloads_tv -p 2 --preview
bin/media_rename rename_from_plex /Volumes/Media/downloads -p 1 --preview
bin/media_rename rename_from_plex /Volumes/Media/downloads_hq -p 3 --preview