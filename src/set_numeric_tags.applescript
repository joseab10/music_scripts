use framework "Foundation"
use framework "AppKit"
use scripting additions

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------
property startNumberField : missing value
property paddingBox : missing value
property paddingStepper : missing value
property paddingValueField : missing value

property titleBox : missing value
property trackBox : missing value
property movementBox : missing value

property setTrackCountBox : missing value
property trackCountField : missing value

property setMovementCountBox : missing value
property movementCountField : missing value

property discBox : missing value
property discField : missing value

property setDiscCountBox : missing value
property discCountField : missing value


--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------
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


--------------------------------------------------------------------------------
-- Dialog
--------------------------------------------------------------------------------
on showDialog(selectedTracks)
	
	set trackTotal to count selectedTracks
	
	set alert to current application's NSAlert's alloc()'s init()
	alert's setMessageText:"Set Numeric Tags"
	alert's setInformativeText:("Choose how to set numeric tags." & linefeed & "JAB 2026")
	
	set accessoryView to current application's NSView's alloc()'s initWithFrame:{{0, 0}, {320, 320}}
	
	------------------------------------------------------------------------
	-- Starting number
	------------------------------------------------------------------------
	set label to current application's NSTextField's labelWithString:"Starting number:"
	label's setFrame:{{20, 300}, {120, 20}}
	accessoryView's addSubview:label
	
	set startNumberField to current application's NSTextField's alloc()'s initWithFrame:{{150, 297}, {80, 24}}
	startNumberField's setStringValue:"1"
	accessoryView's addSubview:startNumberField
	
	------------------------------------------------------------------------
	-- Apply to
	------------------------------------------------------------------------
	set applyLabel to current application's NSTextField's labelWithString:"Apply to:"
	applyLabel's setFrame:{{20, 270}, {100, 20}}
	accessoryView's addSubview:applyLabel
	
	set titleBox to current application's NSButton's alloc()'s initWithFrame:{{40, 240}, {220, 20}}
	titleBox's setButtonType:(current application's NSSwitchButton)
	titleBox's setTitle:"Title (as prefix)"
	titleBox's setTarget:me
	titleBox's setAction:"titleBoxChanged:"
	accessoryView's addSubview:titleBox
	
	------------------------------------------------------------------------
	-- Zero padding
	------------------------------------------------------------------------
	set paddingBox to current application's NSButton's alloc()'s initWithFrame:{{60, 210}, {180, 20}}
	paddingBox's setButtonType:(current application's NSSwitchButton)
	paddingBox's setTitle:"Zero pad title"
	paddingBox's setTarget:me
	paddingBox's setAction:"paddingBoxChanged:"
	paddingBox's setEnabled:false
	accessoryView's addSubview:paddingBox
	
	-- set paddingLabel to current application's NSTextField's labelWithString:"Positions:"
	-- paddingLabel's setFrame:{{110, 210}, {70, 20}}
	-- accessoryView's addSubview:paddingLabel
	
	set paddingValueField to current application's NSTextField's alloc()'s initWithFrame:{{200, 207}, {50, 24}}
	paddingValueField's setStringValue:"2"
	paddingValueField's setEnabled:false
	accessoryView's addSubview:paddingValueField
	
	set paddingStepper to current application's NSStepper's alloc()'s initWithFrame:{{270, 210}, {30, 25}}
	paddingStepper's setMinValue:1
	paddingStepper's setMaxValue:5
	paddingStepper's setIntegerValue:2
	paddingStepper's setTarget:me
	paddingStepper's setAction:"paddingChanged:"
	paddingStepper's setEnabled:false
	accessoryView's addSubview:paddingStepper
	
	set trackBox to current application's NSButton's alloc()'s initWithFrame:{{40, 180}, {220, 20}}
	trackBox's setButtonType:(current application's NSSwitchButton)
	trackBox's setTitle:"Track number"
	accessoryView's addSubview:trackBox
	
	set movementBox to current application's NSButton's alloc()'s initWithFrame:{{40, 150}, {220, 20}}
	movementBox's setButtonType:(current application's NSSwitchButton)
	movementBox's setTitle:"Movement number"
	accessoryView's addSubview:movementBox
	
	------------------------------------------------------------------------
	-- Totals
	------------------------------------------------------------------------
	set totalLabel to current application's NSTextField's labelWithString:"Totals:"
	totalLabel's setFrame:{{20, 110}, {100, 20}}
	accessoryView's addSubview:totalLabel
	
	set setTrackCountBox to current application's NSButton's alloc()'s initWithFrame:{{40, 80}, {200, 20}}
	setTrackCountBox's setButtonType:(current application's NSSwitchButton)
	setTrackCountBox's setTitle:"Set track count:"
	accessoryView's addSubview:setTrackCountBox
	
	set trackCountField to current application's NSTextField's alloc()'s initWithFrame:{{220, 77}, {80, 24}}
	trackCountField's setStringValue:(trackTotal as text)
	trackCountField's setAlignment:(current application's NSTextAlignmentRight)
	accessoryView's addSubview:trackCountField
	
	set setMovementCountBox to current application's NSButton's alloc()'s initWithFrame:{{40, 50}, {220, 20}}
	setMovementCountBox's setButtonType:(current application's NSSwitchButton)
	setMovementCountBox's setTitle:"Set movement count:"
	accessoryView's addSubview:setMovementCountBox
	
	set movementCountField to current application's NSTextField's alloc()'s initWithFrame:{{220, 47}, {80, 24}}
	movementCountField's setStringValue:(trackTotal as text)
	movementCountField's setAlignment:(current application's NSTextAlignmentRight)
	accessoryView's addSubview:movementCountField
	
	------------------------------------------------------------------------
	-- Disc number
	------------------------------------------------------------------------
	set discBox to current application's NSButton's alloc()'s initWithFrame:{{40, 20}, {80, 20}}
	discBox's setButtonType:(current application's NSSwitchButton)
	discBox's setTitle:"Set disc #:"
	accessoryView's addSubview:discBox
	
	
	set discField to current application's NSTextField's alloc()'s initWithFrame:{{140, 17}, {40, 24}}
	discField's setStringValue:"1"
	discField's setAlignment:(current application's NSTextAlignmentRight)
	accessoryView's addSubview:discField
	
	--------------------------------------------------------------------------------
	-- Disc count
	--------------------------------------------------------------------------------
	set setDiscCountBox to current application's NSButton's alloc()'s initWithFrame:{{200, 20}, {40, 20}}
	setDiscCountBox's setButtonType:(current application's NSSwitchButton)
	setDiscCountBox's setTitle:"of:"
	accessoryView's addSubview:setDiscCountBox
	
	set discCountField to current application's NSTextField's alloc()'s initWithFrame:{{260, 17}, {40, 24}}
	discCountField's setStringValue:"1"
	discCountField's setAlignment:(current application's NSTextAlignmentRight)
	accessoryView's addSubview:discCountField
	
	alert's setAccessoryView:accessoryView
	
	alert's addButtonWithTitle:"Apply"
	alert's addButtonWithTitle:"Cancel"
	
	set result to alert's runModal()
	
	if result = (current application's NSAlertFirstButtonReturn) then
		my applyChanges(selectedTracks)
	end if
	
end showDialog


--------------------------------------------------------------------------------
-- UI Event Handlers
--------------------------------------------------------------------------------
on titleBoxChanged:sender
	set titleEnabled to ((sender's state()) as integer = 1)
	
	paddingBox's setEnabled:titleEnabled
	paddingStepper's setEnabled:titleEnabled
end titleBoxChanged:


on paddingBoxChanged:sender
	set paddingEnabled to ((sender's state()) as integer = 1)
	
	paddingStepper's setEnabled:titleEnabled
end titleBoxChanged:


on paddingChanged:sender
	set value to sender's integerValue()
	paddingValueField's setIntegerValue:value
end paddingChanged:


--------------------------------------------------------------------------------
-- Apply changes
--------------------------------------------------------------------------------
on applyChanges(selectedTracks)
	
	set startNumber to startNumberField's integerValue()
	set padEnabled to ((paddingBox's state()) as integer = 1)
	set padLength to paddingStepper's integerValue()
	
	set applyTitle to ((titleBox's state()) as integer = 1)
	set applyTrack to ((trackBox's state()) as integer = 1)
	set applyMovement to ((movementBox's state()) as integer = 1)
	
	
	set trackTotal to trackCountField's integerValue()
	set movementTotal to movementCountField's integerValue()
	
	set setTrackTotal to ((setTrackCountBox's state()) as integer = 1)
	set setMovementTotal to ((setMovementCountBox's state()) as integer = 1)
	
	set setDisc to ((discBox's state()) as integer = 1)
	set discNumber to discField's integerValue()
	
	set setDiscCount to ((setDiscCountBox's state()) as integer = 1)
	set discCount to discCountField's integerValue()
	
	set setDisc to ((discBox's state()) as integer = 1)
	set discNumber to discField's integerValue()
	
	tell application "Music"
		
		set trackCounter to 0
		
		repeat with t in selectedTracks
			
			set n to startNumber + trackCounter
			
			
			if applyTrack then
				set track number of t to n
			end if
			
			
			if applyMovement then
				set movement number of t to n
			end if
			
			
			if applyTitle then
				
				set prefix to n as text
				
				if padEnabled then
					repeat while (length of prefix) < padLength
						set prefix to "0" & prefix
					end repeat
				end if
				
				set name of t to prefix & " " & (name of t)
				
			end if
			
			
			if setTrackTotal then
				set track count of t to trackTotal
			end if
			
			
			if setMovementTotal then
				set movement count of t to movementTotal
			end if
			
			
			if setDisc then
				set disc number of t to discNumber
			end if
			
			if setDiscCount then
				set disc count of t to discCount
			end if
			
			set trackCounter to trackCounter + 1
			
		end repeat
		
	end tell
	
end applyChanges
