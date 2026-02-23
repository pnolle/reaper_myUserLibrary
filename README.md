#  REAPER user library changes

This repo keeps the changes I made to files in my REAPER user library like updated JS FX or VST settings.

## Contents

* ``Data/ix_keymaps/``: MIDI keymaps for the effect ``MIDI Map To Key v2``.
* ``Effects/ix/``: MIDI effects

The repo reflects the state of these folders in version ``v7.28``. Check with later versions if it still fits.

## How to use

Clone this repo into the ``Users\<usr>\Library\Application Support\REAPER\`` folder.

## How to use REAPER, ReaPack and SWS extensions and all of their settings and fx from several MacOS accounts

Install REAPER portably, meaning: 

* Move REAPER.app and settings to a shared folder, e.g. ``/Users/Shared/REAPER``
* Move all contents of the ``Users\<usr>\Library\Application Support\REAPER\`` folder over to the shared folder
* Clone this repo into the ``/Users/Shared/REAPER`` folder
* Move your Reaper projects from ``Users\<usr>\Music\Reaper Projects\`` into a shared folder as well, e.g. ``/Users/Shared/_ReaperProjects``
* Find & replace all reference of the old media folder ``Users\<usr>\Music\Reaper Projects\`` in all project files and replace them with the new one ``/Users/Shared/_ReaperProjects``. ➡️ This can be a lot. I opened up the whole projects folder with VS Code and it finds 200.000 entries max. I deleted all my .rpp-bak files and still I had to go 5-6 times up to the maximum number of findings until all got replaced.


## EEL2 language learnings

### Arrays

EEL2 uses a flat, linear memory pool for arrays. When you declare an array, it doesn't track its size—it just allocates based on the largest index you access. So:

* map[i] with i going 0-127 allocates indices 0-127
* history[16] also starts allocating at index 0
* They collide and corrupt each other

#### Best Practic

* Declare all arrays in @init in the order you'll use them
* use explicit offsets (like ``historyOffset = 200``) and add it when assigning and reading out values