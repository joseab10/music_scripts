(*
    Track2Work.applescript

    Extract Work and Movement tags from Music track titles.

    macOS 11.7 / Music.app Script Menu

    v0.1
*)

use AppleScript version "2.7"
use framework "Foundation"
use framework "AppKit"
use scripting additions

------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------
on run
	
	tell application "Music"
		set selectedTracks to selection
	end tell
	
	if selectedTracks = {} then
		display alert "No tracks selected."
		return
	end if
	
	my showDialog(selectedTracks)
	
end run


------------------------------------------------------------------------
-- Confirmation dialog
------------------------------------------------------------------------
on showDialog(selectedTracks)

    set alert to current application's NSAlert's alloc()'s init()
    alert's setMessageText:"Confirm Changes"
    alert's setInformativeText:"The following Work names will be written:"

    set previewText to ""
    repeat with t in selectedTracks
        tell application "Music"
            set newWork to name of t
        end tell
        set previewText to previewText & newWork & return
    end repeat

    set scroll to current application's NSScrollView's alloc()'s initWithFrame:{{0, 0}, {500, 250}}

    set textView to current application's NSTextView's alloc()'s initWithFrame:{{0, 0}, {500, 250}}
    textView's setEditable:false
    textView's setString:previewText

    scroll's setDocumentView:textView
    scroll's setHasVerticalScroller:true

    alert's setAccessoryView:scroll

    alert's addButtonWithTitle:"Confirm"
    alert's addButtonWithTitle:"Cancel"

    set response to alert's runModal()

    if response = (current application's NSAlertFirstButtonReturn) then
        my applyChanges(selectedTracks)
    end if

end showDialog


------------------------------------------------------------------------
-- Apply changes
------------------------------------------------------------------------
on applyChanges(selectedTracks)
    repeat with t in selectedTracks
        tell application "Music"
            set workName to name of t
            set work of t to workName
        end tell
    end repeat
end applyChanges