#  REAPER user library changes

This repo keeps the changes I made to files in my REAPER user library like updated JS FX or VST settings.

## How to use

Clone this repo into the ``Users\<usr>\Library\Application Support\REAPER\`` folder.

## How to use REAPER, ReaPack and SWS extensions and all of their settings and fx from several MacOS accounts

Install REAPER portably, meaning: 

* Move REAPER.app and settings to a shared folder, e.g. ``/Users/Shared/REAPER``
* Move all contents of the ``Users\<usr>\Library\Application Support\REAPER\`` folder over to the shared folder
* Clone this repo into the ``/Users/Shared/REAPER`` folder
* Move your Reaper projects from ``Users\<usr>\Music\Reaper Projects\`` into a shared folder as well, e.g. ``/Users/Shared/_ReaperProjects``
* Find & replace all reference of the old media folder ``Users\<usr>\Music\Reaper Projects\`` in all project files and replace them with the new one ``/Users/Shared/_ReaperProjects``. ➡️ This can be a lot. I opened up the whole projects folder with VS Code and it finds 200.000 entries max. I deleted all my .rpp-bak files and still I had to go 5-6 times up to the maximum number of findings until all got replaced.

## Contents

* ``Data/ix_keymaps/``: MIDI keymaps for the effect ``MIDI Map To Key v2``.
* ``Effects/ix/``: MIDI effects

The repo reflects the state of these folders in version ``v7.61``. Check with later versions if it still fits.

## Effects

### MIDI Map To Key v2

Enhanced ``Map To Key`` with
* a more compact configuration file format
* mapping capabilities for CC messages
* an enhanced @gfx display that shows configured mappings as well as incoming and outgoing MIDI messages

#### Best practices

Use case for this JSFX: Using external drum pads with a sampler on a track, that assigns sound samples to certain notes. 
* If the notes that are sent by the devices cannot be configured (or to leave them untouched), use the note mapping capabilities to map single notes to other ones. 
* Use the CC mapping capabilities and "MIDI link" (not "Learn" because this works with raw MIDI data, outside the FX chain!) to a property of an effect further down in the FX chain to keep the mapping untouched while just turning this effect on and off to switch between devices.

## EEL2 language learnings

### Arrays

EEL2 uses a flat, linear memory pool for arrays. When you declare an array, it doesn't track its size—it just allocates based on the largest index you access. So:

* map[i] with i going 0-127 allocates indices 0-127
* history[16] also starts allocating at index 0
* They collide and corrupt each other

#### Best Practice

* Declare all arrays in @init in the order you'll use them
* use explicit offsets (like ``historyOffset = 200``) and add it when assigning and reading out values


### Memory layout

EEL2 memory works quite different from statically-typed languages.

EEL2 has a single, flat memory space. Everything—integers, strings, arrays—is just stored as numbers in a linear block of memory. There's no enforced type system.

Here's how it works:

1. %d interprets a value as a number → prints it as decimal
2. %s interprets a value as a memory address → reads bytes from that address until it finds a null terminator, printing the string

Example:

* ccMap[idx] = 15 (some integer you stored)
* %d prints: 15
* %s prints: whatever string is at memory location 15

Why does this work with notes but not CC?

```
Memory layout:
Loc 0-127:    Note name strings ("C-1", "C#-1", ..., "B9")  ← Created by InitNoteNames()
Loc 128-139:  Individual note chars ("C", "C#", etc.)
Loc 150+:     ccMap array [in_ch, in_cc, out_ch, out_cc, ...]
```

When you map notes 0-127 to output 0-127, the values happen to match the string buffer locations, so %s accidentally works. But ccMap stores arbitrary values (1-16 channels, 0-127 CC numbers)—those values don't correspond to valid string locations, so you get garbage.

JSFX/EEL2 has zero type checking, so you can accidentally read/write to any memory location. In typed languages, this would be caught at compile time.


## MIDI knowledge

### midisend() / midirecv()

Docs: https://www.reaper.fm/sdk/js/midi.php#js_midi

The first parameter to midisend isn't part of the MIDI message itself—it's the offset (in samples into the current processing block). The actual MIDI message has three bytes:

* msg1 (status byte): Encodes both the message type and channel
  * Upper 4 bits = message type (0x8-0xF)
  * Lower 4 bits = channel (0-15)
* msg2: First data byte (meaning depends on message type)
* msg3: Second data byte (meaning depends on message type)

Common message types:

```
0x8_ = Note Off
0x9_ = Note On
0xA_ = Polyphonic Pressure (Aftertouch)
0xB_ = Control Change (CC)
0xC_ = Program Change
0xD_ = Channel Pressure
0xE_ = Pitch Bend
```

So in the examples:


* $x90 = 0x9 (Note On) + 0x0 (channel 0)
* $xD4 = 0xD (Channel Pressure) + 0x4 (channel 4)

For a CC message, you'd use 0xB_:

```
midisend(0, $xB0, 7, 100);  // offset, CC message type, channel 0, CC#7 (volume), value 100
```

Offset usage:
```
midisend(10,$xD4,50); // set channel pressure on channel 4 to 50, at 10 samples into current block
```

"At 10 samples into current block" means REAPER processes audio in chunks. The first parameter specifies the exact sample offset within that chunk for precise timing.