(*
------------------------------------------------------------------------------
Album Metadata.applescript

Set album rating and album recommendation flags for the selected albums.

Rating options:
    Clear
    Computed
    ?
    ??
    ???
    ????
    ?????

Recommendation:
    Clear
    Favorite
    Suggest Less

Works on unique albums represented by the selected tracks.
------------------------------------------------------------------------------
*)

use AppleScript version "2.7"
use framework "Foundation"
use framework "AppKit"
use scripting additions


on run()

    tell application "Music"
        set selectedTracks to selection
    end tell

    if (count of selectedTracks) = 0 then
        display dialog "Please select one or more tracks." buttons {"OK"} default button 1
        return
    end if

    --------------------------------------------------------------------------
    -- Collect one representative track for each album
    --------------------------------------------------------------------------
    set albumTracks to {}
    set albumKeys to {}

    tell application "Music"

        repeat with t in selectedTracks
            try
                set albumKey to (album artist of t) & "||" & (album of t)

                if albumKey is not in albumKeys then
                    set end of albumKeys to albumKey
                    set end of albumTracks to t
                end if
            end try
        end repeat
    end tell

    --------------------------------------------------------------------------
    -- Build dialog
    --------------------------------------------------------------------------
    set alert to current application's NSAlert's alloc()'s init()
    alert's setMessageText:"Album Metadata"
    alert's setInformativeText:("Albums selected: " & (count of albumTracks))

    set view to current application's NSView's alloc()'s initWithFrame:{{0, 0}, {430, 120}}

    --------------------------------------------------------------------------
    -- Rating
    --------------------------------------------------------------------------
    set ratingCheck to current application's NSButton's alloc()'s initWithFrame:{{10, 82}, {140, 20}}
    ratingCheck's setButtonType:(current application's NSSwitchButton)
    ratingCheck's setTitle:"Set album rating"
    ratingCheck's setState:1
    view's addSubview:ratingCheck

    set ratingPopup to current application's NSPopUpButton's alloc()'s initWithFrame:{{180, 78}, {180, 26}}

    set ratingItems to {Â
        {"Clear", 0}, Â
        {"Computed", 1}, Â
        {"?", 20}, Â
        {"??", 40}, Â
        {"???", 60}, Â
        {"????", 80}, Â
        {"?????", 100} Â
    }

    repeat with entry in ratingItems

        set titleText to item 1 of entry
        set value to item 2 of entry

        set menuItem to (ratingPopup's menu()'s addItemWithTitle:titleText action:(missing value) keyEquivalent:"")

        menuItem's setRepresentedObject:value

    end repeat

    ratingPopup's selectItemAtIndex:0 -- Clear

    view's addSubview:ratingPopup

    --------------------------------------------------------------------------
    -- Recommendation
    --------------------------------------------------------------------------
    set recCheck to current application's NSButton's alloc()'s initWithFrame:{{10, 42}, {170, 20}}
    recCheck's setButtonType:(current application's NSSwitchButton)
    recCheck's setTitle:"Set recommendation"
    recCheck's setState:1
    view's addSubview:recCheck

    set recPopup to current application's NSPopUpButton's alloc()'s initWithFrame:{{180, 38}, {180, 26}}

    set recommendationItems to {Â
        {"Clear", false, false}, Â
        {"Favorite", true, false}, Â
        {"Suggest Less", false, true} Â
    }

    repeat with entry in recommendationItems
        set menuItem to (recPopup's menu()'s addItemWithTitle:(item 1 of entry) action:(missing value) keyEquivalent:"")

        menuItem's setRepresentedObject:{item 2 of entry, item 3 of entry}
    end repeat

    recPopup's selectItemAtIndex:0

    view's addSubview:recPopup

    alert's setAccessoryView:view

    alert's addButtonWithTitle:"Cancel"
    alert's addButtonWithTitle:"Apply"

    set response to alert's runModal()

    if response = (current application's NSAlertFirstButtonReturn) then
        return
    end if

    --------------------------------------------------------------------------
    -- Read controls
    --------------------------------------------------------------------------
    set doRating to ((ratingCheck's state()) as integer = 1)
    set doRecommendation to ((recCheck's state()) as integer = 1)

    set ratingChoice to (ratingPopup's titleOfSelectedItem()) as text
    set recommendationChoice to (recPopup's titleOfSelectedItem()) as text

    --------------------------------------------------------------------------
    -- Apply
    --------------------------------------------------------------------------
    tell application "Music"

        repeat with t in albumTracks

            --------------------------------------------------------------
            -- Album Rating
            --------------------------------------------------------------
            if doRating then
                set ratingValue to ((ratingPopup's selectedItem()'s representedObject()) as integer)
                set album rating of t to ratingValue 
            end if

            --------------------------------------------------------------
            -- Recommendation
            --------------------------------------------------------------
            if doRecommendation then
                set {loveFlag, dislikeFlag} to (recPopup's selectedItem()'s representedObject())

                set album loved of t to loveFlag
                set album disliked of t to dislikeFlag
            end if

        end repeat

    end tell

end run