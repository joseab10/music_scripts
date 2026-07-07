use framework "Foundation"
use framework "AppKit"
use scripting additions


--------------------------------------------------------------------------------
-- Main entry point
--------------------------------------------------------------------------------
on run
	tell application "Music"
		set selectedTracks to selection
	end tell
	
	if selectedTracks = {} then
		display alert "No tracks selected in Music."
		return
	end if
	
	-- Default options
	set state to {Â
        includeWork:true, Â
        includeNumber:true, Â
        includeMovement:true, Â
        useRoman:true, Â
        workSeparator:": ", Â
        numberSeparator:". "Â
    }
	
	my showDialog(selectedTracks, state)
end run


--------------------------------------------------------------------------------
-- Show the dialog.
-- Rebuilds itself whenever the user presses Refresh.
--------------------------------------------------------------------------------
on showDialog(selectedTracks, state)
	
	----------------------------------------------------------------------------
	-- Build the alert
	----------------------------------------------------------------------------
	set alert to current application's NSAlert's alloc()'s init()
	alert's setMessageText:"Rename Classical Titles"
	alert's setInformativeText:("Choose how to build the new title." & linefeed & "JAB 2026")
	
	----------------------------------------------------------------------------
	-- Build accessory view
	----------------------------------------------------------------------------
	set accessoryView to current application's NSView's alloc()'s initWithFrame:{{0, 0}, {220, 170}}
	
	----------------------------------------------------------------------------
	-- Checkboxes
	----------------------------------------------------------------------------
	set workBox to current application's NSButton's alloc()'s initWithFrame:{{20, 150}, {250, 20}}
	workBox's setButtonType:(current application's NSSwitchButton)
	workBox's setTitle:"Include work"
	workBox's setState:(includeWork of state)
	accessoryView's addSubview:workBox
	
	set numberBox to current application's NSButton's alloc()'s initWithFrame:{{20, 125}, {250, 20}}
	numberBox's setButtonType:(current application's NSSwitchButton)
	numberBox's setTitle:"Include movement number"
	numberBox's setState:(includeNumber of state)
	accessoryView's addSubview:numberBox
	
	set movementBox to current application's NSButton's alloc()'s initWithFrame:{{20, 100}, {250, 20}}
	movementBox's setButtonType:(current application's NSSwitchButton)
	movementBox's setTitle:"Include movement title"
	movementBox's setState:(includeMovement of state)
	accessoryView's addSubview:movementBox
	
	set romanBox to current application's NSButton's alloc()'s initWithFrame:{{20, 75}, {250, 20}}
	romanBox's setButtonType:(current application's NSSwitchButton)
	romanBox's setTitle:"Use Roman numerals"
	romanBox's setState:(useRoman of state)
	accessoryView's addSubview:romanBox
	
	----------------------------------------------------------------------------
	-- Work Separator field
	----------------------------------------------------------------------------
	set workSeparatorLabel to current application's NSTextField's labelWithString:"Work Separator:"
	workSeparatorLabel's setFrame:{{20, 50}, {120, 20}}
	accessoryView's addSubview:workSeparatorLabel
	
	set workSeparatorField to current application's NSTextField's alloc()'s initWithFrame:{{140, 47}, {60, 24}}
	workSeparatorField's setStringValue:(workSeparator of state)
	accessoryView's addSubview:workSeparatorField
	
	----------------------------------------------------------------------------
	-- Number Separator field
	----------------------------------------------------------------------------
	set numberSeparatorLabel to current application's NSTextField's labelWithString:"Number Separator:"
	numberSeparatorLabel's setFrame:{{20, 25}, {120, 20}}
	accessoryView's addSubview:numberSeparatorLabel
	
	set numberSeparatorField to current application's NSTextField's alloc()'s initWithFrame:{{140, 22}, {60, 24}}
	numberSeparatorField's setStringValue:(numberSeparator of state)
	accessoryView's addSubview:numberSeparatorField
	
	alert's setAccessoryView:accessoryView
	
	----------------------------------------------------------------------------
	-- Buttons
	----------------------------------------------------------------------------
	alert's addButtonWithTitle:"Rename"
	alert's addButtonWithTitle:"Cancel"
	
	set response to alert's runModal()
	
	----------------------------------------------------------------------------
	-- Read the current UI state back
	----------------------------------------------------------------------------
	set includeWork of state to ((workBox's state()) as integer = 1)
	set includeNumber of state to ((numberBox's state()) as integer = 1)
	set includeMovement of state to ((movementBox's state()) as integer = 1)
	set useRoman of state to ((romanBox's state()) as integer = 1)
	
	set workSeparator of state to (workSeparatorField's stringValue() as text)
	set numberSeparator of state to (numberSeparatorField's stringValue() as text)
	
	----------------------------------------------------------------------------
	-- Button handling
	----------------------------------------------------------------------------
	if response = (current application's NSAlertFirstButtonReturn) then
		
		-- Generate all new titles
		set newTitles to {}
		
		repeat with t in selectedTracks
			set end of newTitles to makeTitle(t, state)
		end repeat
		
		if my showPreviewDialog(newTitles) then
			-- Rename
			tell application "Music"
				repeat with i from 1 to count of selectedTracks
					set name of item i of selectedTracks to item i of newTitles
				end repeat
			end tell
			
			return
		end if
	else
		
		-- Cancel
		return
		
	end if
	
end showDialog


on showPreviewDialog(titleList)
	
	set alert to current application's NSAlert's alloc()'s init()
	
	alert's setMessageText:"Confirm new titles"
	
	set previewText to my joinList(titleList, linefeed & linefeed)
	
	alert's setInformativeText:previewText
	
	alert's addButtonWithTitle:"Confirm"
	alert's addButtonWithTitle:"Cancel"
	
	set response to alert's runModal()
	
	return response = current application's NSAlertFirstButtonReturn
	
end showPreviewDialog


--------------------------------------------------------------------------------
-- Build a title for one track according to the current options
--------------------------------------------------------------------------------
on makeTitle(theTrack, state)
	
	tell application "Music"
		set theWork to work of theTrack
		set theMovement to movement of theTrack
		set theNumber to movement number of theTrack
	end tell
	
	set parts to {}
	
	if includeWork of state then
		if theWork is not "" then
			set end of parts to theWork
		end if
		
		if includeNumber of state and theNumber is not missing value and theNumber is not 0 then
			set end of parts to (workSeparator of state as text)
		end if
	end if
	
	if includeNumber of state then
		if theNumber is not missing value and theNumber is not 0 then
			
			if useRoman of state then
				set end of parts to my romanNumeral(theNumber)
			else
				set end of parts to (theNumber as text)
			end if
			
			if includeMovement of state and theMovement is not "" then
				set end of parts to (numberSeparator of state as text)
			end if
			
		end if
	end if
	
	if includeMovement of state then
		if theMovement is not "" then
			set end of parts to theMovement
		end if
	end if
	
	return my joinList(parts, "")
	
end makeTitle


--------------------------------------------------------------------------------
-- Join a list of strings with a separator
--------------------------------------------------------------------------------
on joinList(theList, separator)
	
	if (count theList) = 0 then return ""
	
	set resultText to item 1 of theList
	
	repeat with i from 2 to count theList
		set resultText to resultText & separator & item i of theList
	end repeat
	
	return resultText
	
end joinList


--------------------------------------------------------------------------------
-- Roman numerals
--------------------------------------------------------------------------------
on romanNumeral(n)
	
	set numerals to {Â
		"I", "II", "III", "IV", "V", Â
		"VI", "VII", "VIII", "IX", "X", Â
		"XI", "XII", "XIII", "XIV", "XV", Â
		"XVI", "XVII", "XVIII", "XIX", Â
		"XX"Â
	}
	
	try
		set n to n as integer
	on error
		return n as text
	end try
	
	if n >= 1 and n <= (count numerals) then
        return item n of numerals
    else
        return n as text
    end if
	
end romanNumeral
