#!/bin/bash

SRC="/Volumes/Shared/REAPER"                # <-- alten REAPER-Ordner hier eintragen
DEST="/Volumes/Shared/REAPER_movehouse"     # <-- Zielordner, wird neu angelegt

mkdir -p "$DEST"

# Ordner
for folder in ColorThemes KeyMaps LangPack MenuSets MIDINoteNames OSC presets ProjectTemplates TrackTemplates Data Effects FXChains; do
  if [ -d "$SRC/$folder" ]; then
    cp -R "$SRC/$folder" "$DEST/$folder"
    echo "Kopiert: $folder"
  else
    echo "FEHLT: $folder"
  fi
done

# Einzeldateien
for file in reaper-kb.ini reaper-menu.ini reaper-mouse.ini reaper-themeconfig.ini reaper-fxtags.ini "S&M.ini" sws-autocoloricon.ini; do
  if [ -f "$SRC/$file" ]; then
    cp "$SRC/$file" "$DEST/$file"
    echo "Kopiert: $file"
  else
    echo "FEHLT: $file"
  fi
done

echo "Fertig. Inhalt von $DEST prüfen, dann manuell in den neuen REAPER-Resource-Ordner mergen."