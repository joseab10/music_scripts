use framework "Foundation"
use framework "AppKit"
use scripting additions


--------------------------------------------------------------------------------
-- UI properties
--------------------------------------------------------------------------------
property tagPopup : missing value
property sedField : missing value

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
-- Main dialog
--------------------------------------------------------------------------------
on showDialog(selectedTracks)

    set alert to current application's NSAlert's alloc()'s init()
    alert's setMessageText:"Apply SED to Field"
    alert's setInformativeText:("Run a SED command on a Field." & linefeed & "JAB 2026")

    set accessoryView to current application's NSView's alloc()'s initWithFrame:{{0, 0}, {500, 130}}

    ------------------------------------------------------------------------
    -- Tag
    ------------------------------------------------------------------------
    set label to current application's NSTextField's labelWithString:"Field:"
    label's setFrame:{{20, 80}, {60, 20}}
    accessoryView's addSubview:label

    set tagPopup to current application's NSPopUpButton's alloc()'s initWithFrame:{{90, 76}, {250, 26}}

    tagPopup's addItemsWithTitles:{Â
        "Title", Â
        "Album", Â
        "Album Artist", Â
        "Artist", Â
        "Category", Â
        "Comments", Â
        "Composer", Â
        "Grouping", Â
        "Work", Â
        "Movement", Â
        "-", Â
        "Sort Title", Â
        "Sort Album", Â
        "Sort Album Artist", Â
        "Sort Artist", Â
        "Sort Composer"Â
    }

    accessoryView's addSubview:tagPopup

    ------------------------------------------------------------------------
    -- sed expression
    ------------------------------------------------------------------------

    set label to current application's NSTextField's labelWithString:"sed:"
    label's setFrame:{{20, 40}, {60, 20}}
    accessoryView's addSubview:label

    set sedField to current application's NSTextField's alloc()'s initWithFrame:{{90, 36}, {380, 24}}
    sedField's setStringValue:"s/find/replace/g"
    accessoryView's addSubview:sedField

    alert's setAccessoryView:accessoryView

    alert's addButtonWithTitle:"Preview"
    alert's addButtonWithTitle:"Cancel"

    set response to alert's runModal()

    if response = (current application's NSAlertFirstButtonReturn) then
        my previewChanges(selectedTracks)
    end if

end showDialog


--------------------------------------------------------------------------------
-- Show a preview of the applied changes
--------------------------------------------------------------------------------
on previewChanges(selectedTracks)

    set tagName to (tagPopup's titleOfSelectedItem()) as text
    set sedExpr to (sedField's stringValue()) as text

    set previewText to ""

    repeat with t in selectedTracks

        set oldValue to my getTag(t, tagName)
        set newValue to my applySed(oldValue, sedExpr)

        set previewText to previewText & newValue & return

    end repeat

    my showConfirmation(selectedTracks, tagName, sedExpr, previewText)

end previewChanges


--------------------------------------------------------------------------------
-- Confirmation dialog
--------------------------------------------------------------------------------
on showConfirmation(selectedTracks, tagName, sedExpr, previewText)

    set alert to current application's NSAlert's alloc()'s init()
    alert's setMessageText:"Confirm Changes"
    alert's setInformativeText:"The following values will be written:"

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
        my applyChanges(selectedTracks, tagName, sedExpr)
    end if

end showConfirmation


--------------------------------------------------------------------------------
-- Apply Changes to Field
--------------------------------------------------------------------------------
on applyChanges(selectedTracks, tagName, sedExpr)

    repeat with t in selectedTracks

        set oldValue to my getTag(t, tagName)
        set newValue to my applySed(oldValue, sedExpr)

        my setTag(t, tagName, newValue)

    end repeat

end applyChanges


--------------------------------------------------------------------------------
-- Apply SED command to string
--------------------------------------------------------------------------------
on applySed(theText, sedExpr)

    if theText is missing value then return ""

    set theText to theText as text

    set escapedText to quoted form of theText
    set escapedSed to quoted form of sedExpr

    set cmd to "printf %s " & escapedText & " | sed -e " & escapedSed

    try
        return do shell script cmd
    on error errMsg number errNum
        display alert "sed error" message errMsg
        error number -128
    end try

end applySed


--------------------------------------------------------------------------------
-- Read a tag
--------------------------------------------------------------------------------
on getTag(t, tagName)

    tell application "Music"

        if tagName = "Title" then
            return name of t

        else if tagName = "Album" then
            return album of t

        else if tagName = "Album Artist" then
            return album artist of t

        else if tagName = "Artist" then
            return artist of t

        else if tagName = "Category" then
            return category of t

        else if tagName = "Comments" then
            return comment of t

        else if tagName = "Composer" then
            return composer of t

        else if tagName = "Grouping" then
            return grouping of t

        else if tagName = "Work" then
            return work of t

        else if tagName = "Movement" then
            return movement of t

        end if

    end tell

end getTag


--------------------------------------------------------------------------------
-- Write a tag
--------------------------------------------------------------------------------
on setTag(t, tagName, value)

    tell application "Music"

        if tagName = "Title" then
            set name of t to value

        else if tagName = "Album" then
            set album of t to value

        else if tagName = "Album Artist" then
            set album artist of t to value

        else if tagName = "Artist" then
            set artist of t to value

        else if tagName = "Category" then
            set category of t to value

        else if tagName = "Comments" then
            set comment of t to value

        else if tagName = "Composer" then
            set composer of t to value

        else if tagName = "Grouping" then
            set grouping of t to value

        else if tagName = "Work" then
            set work of t to value

        else if tagName = "Movement" then
            set movement of t to value

        end if

    end tell

end setTag