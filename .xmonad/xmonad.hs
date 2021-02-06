-- XMonad config file
-- Date: 02-01-21

-------------------------------------------------------------------------------
-- IMPORT 
import XMonad
import Data.Monoid
import System.Exit
import System.Directory
    -- Actions
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)
import XMonad.Actions.CycleWS (toggleWS', moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import qualified XMonad.Actions.TreeSelect
import XMonad.Actions.OnScreen
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.WorkspaceNames
import qualified XMonad.Actions.Search

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.WorkspaceHistory
import XMonad.Hooks.InsertPosition

import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spiral
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed
import XMonad.Layout.ThreeColumns

import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- COLOR SCHEME --
miku_magenta = "#e12885"
miku_cyan_light = "#86cecb"
miku_cyan = "#137a7f"
grey = "#373b3e"
light_grey = "#bec8d1"

-------------------------------------------------------------------------------
-- VARIABLES
myFont :: String
myFont = "xft:UbuntuMono Nerd Font Mono:regular:size=12:antialias=true:hinting=true"

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "chrome"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myBorderWidth :: Dimension                  -- UI settings
myBorderWidth = 3

myNormalBorderColor  = miku_cyan_light      -- UI color
myFocusedBorderColor = miku_magenta

myModMask :: KeyMask                        -- modkeys
myModMask = mod4Mask

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


-------------------------------------------------------------------------------
-- Workspaces Setting (clickable) --
xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces = clickable . (map xmobarEscape)
               -- $ [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
               $ [" task ", " OI ", " doc ", " vid ", " dev ", " vbox ", " sys ", " util "]
  where
        clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..8] l,
                      let n = i ]

-------------------------------------------------------------------------------
-- KEY BINDINGS --
myKeys :: String -> [([Char], X ())]
myKeys home = [
         -- Window Actions
           ("M-S-c", killAll)
         , ("M-c", kill1)
         , ("M-m", windows W.focusMaster)  -- Move focus to the master window
         , ("M-j", windows W.focusDown)    -- Move focus to the next window
         , ("M-k", windows W.focusUp)      -- Move focus to the prev window
         , ("M-S-m", windows W.swapMaster) -- Swap the focused window and the master window
         , ("M-S-j", windows W.swapDown)   -- Swap focused window with next window
         , ("M-S-k", windows W.swapUp)     -- Swap focused window with prev window
         , ("M-<Backspace>", promote)      -- Moves focused window to master, others mintain order
         , ("M-S-<Tab>", rotSlavesDown)    -- Rotate all windows except master and keep focus in place
         , ("M-h", sendMessage Shrink)     -- Shrink horiz window width
         , ("M-l", sendMessage Expand)     -- Expand horiz window width
         , ("M-M1-j", sendMessage MirrorShrink)          -- Shrink vert window width
         , ("M-M1-k", sendMessage MirrorExpand)          -- Exoand vert window width
         , ("M-`", toggleWS' ["NSP"])
         -- application trigger
         , ("M-M1-<Return>", spawn ("dmenu_run -c -bw 3 -l 12 -sb \"#137a7f\" -nf \"#bec8d1\" -fn \"" ++ myFont ++ "\""))              -- spawn dmenu
         , ("M-<Return>", spawn(myTerminal))  
         , ("M-b", spawn(myBrowser))
         , ("<Print>", spawn("scrot 'screenshot_%Y-%m-%d-%H$%M%S_$wx$h.png' -e 'mv $f ~/images/shots/'"))
         -- XMonad
         , ("M-q", spawn "xmonad --recompile; xmonad --restart")   -- Restarts xmonad
         , ("M-S-q", io exitSuccess)                               -- Quits xmonad
         -- Increase/decrease windows in the master pane or the stack
         , ("M-S-<Up>", sendMessage (IncMasterN 1))      -- Increase number of clients in master pane
         , ("M-S-<Down>", sendMessage (IncMasterN (-1))) -- Decrease number of clients in master pane
         , ("M-C-<Up>", increaseLimit)                   -- Increase number of windows
         , ("M-C-<Down>", decreaseLimit)                 -- Decrease number of windows
          -- Layouts
         , ("M-<Tab>", sendMessage NextLayout)           -- Switch to next layout       
         , ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
         --, ("M-S-n", sendMessage $ MT.Toggle NOBORDERS)  -- Toggles noborder
         -- Float
         , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile
         -- TABBED
         , ("M-C-h", sendMessage $ pullGroup L)
         , ("M-C-l", sendMessage $ pullGroup R)
         , ("M-C-k", sendMessage $ pullGroup U)
         , ("M-C-j", sendMessage $ pullGroup D)
         , ("M-C-m", withFocused (sendMessage . MergeAll))
         , ("M-C-u", withFocused (sendMessage . UnMerge))
         , ("M-C-/", withFocused (sendMessage . UnMergeAll))
         , ("M-C-.", onGroup W.focusUp')    -- Switch focus to next tab
         , ("M-C-,", onGroup W.focusDown')  -- Switch focus to prev tab
         -- Workspaces
         -- , ("M-t", spawn("xdotool key super+1"))
         -- NamedScratchpad
         , ("M-p", namedScratchpadAction myScratchPads "pulsemixer")
         , ("M-<F9>", namedScratchpadAction myScratchPads "quodlibet")
    ]


------------------------------------------------------------------------
-- NamedScratchpad --
myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "pulsemixer" spawnPulsemixer findPulsemixer managePulsemixer
                , NS "quodlibet" "quodlibet" (className =? "Quodlibet") (customFloating $ W.RationalRect 0.1 0.1 0.8 0.8)
                ]
  where
    spawnPulsemixer  = myTerminal ++ " --title pulsemixer --class pulsemixer -e pulsemixer"
    findPulsemixer   = title =? "pulsemixer"
    managePulsemixer = customFloating $ W.RationalRect 0.45 0.03 0.53 0.17

------------------------------------------------------------------------
-- Layouts:

mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i)  True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
master   = renamed [Replace "master"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           -- $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 6
           $ ResizableTall 1 (3/100) (2/3) []
binary   = renamed [Replace "tall"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           -- $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 6
           $ ResizableTall 1 (3/100) (1/2) []
--magnify  = renamed [Replace "magnify"]
--           $ windowNavigation
--           $ addTabs shrinkText myTabTheme
--           $ subLayout [] (smartBorders Simplest)
--           $ magnifier
--           $ limitWindows 12
--           $ mySpacing 8
--           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 Full
floats   = renamed [Replace "floats"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ limitWindows 20 simplestFloat
grid     = renamed [Replace "grid"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           -- $ subLayout [] (smartBorders Simplest)
           $ limitWindows 12
           $ mySpacing 0
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
--spirals  = renamed [Replace "spirals"]
--           $ windowNavigation
--           $ addTabs shrinkText myTabTheme
--           -- $ subLayout [] (smartBorders Simplest)
--           $ mySpacing' 6
--           $ spiral (6/7)
threeCol = renamed [Replace "threeCol"]
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           -- $ subLayout [] (smartBorders Simplest)
           $ limitWindows 7
           $ mySpacing' 4
           $ ThreeCol 1 (3/100) (1/2)
--threeRow = renamed [Replace "threeRow"]
--           $ windowNavigation
--           $ addTabs shrinkText myTabTheme
--           -- $ subLayout [] (smartBorders Simplest)
--           $ limitWindows 7
--           $ mySpacing' 4
--           -- Mirror takes a layout and rotates it by 90 degrees.
--           -- So we are applying Mirror to the ThreeCol layout.
--           $ Mirror
--           $ ThreeCol 1 (3/100) (1/2)
tabs     = renamed [Replace "tabs"]
           -- I cannot add spacing to this layout because it will
           -- add spacing between window and tabs which looks bad.
           $ tabbed shrinkText myTabTheme

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = "#46d9ff"
                 , inactiveColor       = "#313846"
                 , activeBorderColor   = "#46d9ff"
                 , inactiveBorderColor = "#282c34"
                 , activeTextColor     = "#282c34"
                 , inactiveTextColor   = "#d0d0d0"
                 }

-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
    { swn_font              = "xft:Ubuntu:bold:size=60"
    , swn_fade              = 1.0
    , swn_bgcolor           = "#1c1f24"
    , swn_color             = "#ffffff"
    }

-- The layout hook
myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats
               -- $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
               $ mkToggle (NBFULL ?? EOT) myDefaultLayout
             where
               myDefaultLayout =     binary
                              -- ||| magnify
                                 ||| noBorders monocle
                              -- ||| floats
                                 ||| noBorders tabs
                                 ||| grid
                              -- ||| spirals
                                 ||| threeCol
                                 ||| master
                              -- ||| threeRow
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces, and the names would very long if using clickable workspaces.
     [ title =? "Google Calendar"     --> doShift ( myWorkspaces !! 1 )
     , title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 1 )
     , className =? "mpv"     --> doShift ( myWorkspaces !! 8 )
     --, className =? "Gimp"    --> doShift ( myWorkspaces !! 8 )
     , className =? "Gimp"    --> doFloat
     , title =? "Oracle VM VirtualBox Manager"     --> doFloat
     , className =? "VirtualBox Manager" --> doShift  ( myWorkspaces !! 4 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , className =? "feh" --> doFloat
     ] -- <+> namedScratchpadManageHook myScratchPads
------------------------------------------------------------------------
-- Event handling

-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH event handling to your custom event hooks by
-- combining them with ewmhDesktopsEventHook.
--
--myEventHook = mempty

------------------------------------------------------------------------
-- LOG HOOK

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH logHook actions to your custom log hook by
-- combining it with ewmhDesktopsLogHook.
--
myLogHook = return ()

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add initialization of EWMH support to your custom startup
-- hook by combining it with ewmhDesktopsStartup.
--
myStartupHook :: X ()
myStartupHook = do
          spawnOnce "$HOME/.xmonad/startup"  -- startup
          spawnOnce "nitrogen --restore &"   -- wallpaper
          spawnOnce "sh -c '/usr/bin/nvidia-settings --load-config-only'"  -- nVIDIA server setting 
          --spawnOnce "$HOME/.xmonad/workspace.sh"
--workspacePrepareHook :: X ()
--workspacePrepareHook = do
          
------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main :: IO ()
main = do
    xmproc <- spawnPipe "xmobar -x 0 $HOME/.config/xmobar/xmobar.hs"
    home <- getHomeDirectory
    -- xmobar
    -- xmonad
    xmonad $ ewmh def { 
        handleEventHook = handleEventHook def <+> fullscreenEventHook <+> docksEventHook,
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        -- numlockMask deprecated in 0.9.1
        -- numlockMask        = myNumlockMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        --keys               = myKeys,
        --mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayoutHook,
        manageHook = insertPosition Below Newer -- insert new windows below
                     <+> myManageHook <+> manageDocks <+> namedScratchpadManageHook myScratchPads,
        logHook = workspaceHistoryHook <+> myLogHook <+> dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppCurrent = xmobarColor "#06d6a0" "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#98be65" ""                -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#c792ea" ""        -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor "#bec8d1" "" . shorten 60     -- Title of active window in xmobar
                        , ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>"          -- Separators in xmobar
                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        },
        startupHook        = myStartupHook
        } `additionalKeysP` myKeys home

