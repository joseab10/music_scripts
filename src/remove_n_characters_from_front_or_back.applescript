use framework "Foundation"
use framework "AppKit"
use scripting additions

--------------------------------------------------------------------------------
-- UI properties
--------------------------------------------------------------------------------
property tagPopup : missing value

property countField : missing value
property countStepper : missing value

property frontButton : missing value
property backButton : missing value


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
    alert's setMessageText:"Trim Characters"
    alert's setInformativeText:("Remove N characters from the front or back of a Tag." & linefeed & "JAB 2026")

    set accessoryView to current application's NSView's alloc()'s initWithFrame:{{0, 0}, {250, 100}}

    ------------------------------------------------------------------------
    -- Tag selection
    ------------------------------------------------------------------------
    set label to current application's NSTextField's labelWithString:"Tag:"
    label's setFrame:{{20, 80}, {40, 20}}
    accessoryView's addSubview:label

    set tagPopup to current application's NSPopUpButton's alloc()'s initWithFrame:{{80, 77}, {170, 26}}

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
    -- Number of characters
    ------------------------------------------------------------------------
    set label to current application's NSTextField's labelWithString:"Characters:"
    label's setFrame:{{20, 50}, {90, 20}}
    accessoryView's addSubview:label

    set countField to current application's NSTextField's alloc()'s initWithFrame:{{150, 48}, {50, 24}}
    countField's setStringValue:"1"
    countField's setAlignment:(current application's NSTextAlignmentRight)
    countField's setEnabled:false
    accessoryView's addSubview:countField

    set countStepper to current application's NSStepper's alloc()'s initWithFrame:{{220, 48}, {30, 24}}
    countStepper's setMinValue:1
    countStepper's setMaxValue:100
    countStepper's setIntegerValue:1
    countStepper's setTarget:me
    countStepper's setAction:"stepperChanged:"
    accessoryView's addSubview:countStepper

    ------------------------------------------------------------------------
    -- Front / Back radio buttons
    ------------------------------------------------------------------------
    set frontButton to current application's NSButton's alloc()'s initWithFrame:{{40, 20}, {100, 20}}
    frontButton's setButtonType:(current application's NSRadioButton)
    frontButton's setTitle:"Front"
    frontButton's setState:1
    frontButton's setTarget:me
    frontButton's setAction:"radioChanged:"
    accessoryView's addSubview:frontButton

    set backButton to current application's NSButton's alloc()'s initWithFrame:{{180, 20}, {50, 20}}
    backButton's setButtonType:(current application's NSRadioButton)
    backButton's setTitle:"Back"
    backButton's setState:0
    backButton's setTarget:me
    backButton's setAction:"radioChanged:"
    accessoryView's addSubview:backButton

    alert's setAccessoryView:accessoryView

    alert's addButtonWithTitle:"Apply"
    alert's addButtonWithTitle:"Cancel"

    set response to alert's runModal()

    if response = (current application's NSAlertFirstButtonReturn) then
        my previewChanges(selectedTracks)
    end if

end showDialog


--------------------------------------------------------------------------------
-- Stepper callback
--------------------------------------------------------------------------------
on stepperChanged_(sender)
    countField's setIntegerValue:(sender's integerValue())
end stepperChanged_


--------------------------------------------------------------------------------
-- Radio callback
--------------------------------------------------------------------------------
on radioChanged_(sender)

    if sender is frontButton then
        frontButton's setState:1
        backButton's setState:0
    else
        frontButton's setState:0
        backButton's setState:1
    end if

end radioChanged_

--------------------------------------------------------------------------------
-- Build preview and ask for confirmation
--------------------------------------------------------------------------------
on previewChanges(selectedTracks)

    set tagName to (tagPopup's titleOfSelectedItem()) as text
    set charCount to countField's integerValue()
    set removeFront to ((frontButton's state()) as integer = 1)

    set previewText to ""

    repeat with t in selectedTracks

        set oldValue to my getTag(t, tagName)
        set newValue to my trimText(oldValue, charCount, removeFront)

        set previewText to previewText & newValue & return

    end repeat

    my showConfirmation(selectedTracks, tagName, charCount, removeFront, previewText)

end previewChanges


--------------------------------------------------------------------------------
-- Confirmation dialog
--------------------------------------------------------------------------------
on showConfirmation(selectedTracks, tagName, charCount, removeFront, previewText)

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
        my applyChanges(selectedTracks, tagName, charCount, removeFront)
    end if

end showConfirmation


--------------------------------------------------------------------------------
-- Apply changes
--------------------------------------------------------------------------------
on applyChanges(selectedTracks, tagName, charCount, removeFront)

    repeat with t in selectedTracks

        set oldValue to my getTag(t, tagName)
        set newValue to my trimText(oldValue, charCount, removeFront)

        my setTag(t, tagName, newValue)

    end repeat

end applyChanges


--------------------------------------------------------------------------------
-- Remove characters
--------------------------------------------------------------------------------
on trimText(s, n, removeFront)

    if s is missing value then return ""

    set s to s as text
    set L to length of s

    if n ³ L then return ""

    if removeFront then
        return text (n + 1) thru -1 of s
    else
        return text 1 thru (L - n) of s
    end if

end trimText


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