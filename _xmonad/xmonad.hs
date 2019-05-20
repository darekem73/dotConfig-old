--
import           XMonad                          hiding ((|||))
import           XMonad.Util.SpawnOnce
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.DynamicHooks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Layout.Accordion
import           XMonad.Layout.DecorationMadness
import           XMonad.Layout.Fullscreen
import           XMonad.Layout.Grid
import           XMonad.Layout.LayoutCombinators
import           XMonad.Layout.NoBorders
import           XMonad.Layout.PerWorkspace
import           XMonad.Layout.Renamed
import           XMonad.Layout.Tabbed
-- import           XMonad.Layout.Gaps
import           XMonad.Layout.ResizableTile     -- Resizable Horizontal border
import           XMonad.Layout.ThreeColumns
-- import           XMonad.Layout.Simplest
-- import           XMonad.Layout.SimplestFloat
-- import           XMonad.Layout.SimpleFloat       -- simpleFloat, floating layout
-- import           XMonad.Layout.ToggleLayouts     -- Full window at any time
import           XMonad.Layout.Spacing           -- this makes smart space around windows
import           XMonad.Util.EZConfig
import           XMonad.Util.Run
import           XMonad.Util.Scratchpad
import           XMonad.Actions.CycleWS
-- import           XMonad.Prompt
-- import           XMonad.Prompt.Input
import           XMonad.Actions.FloatKeys
import qualified XMonad.StackSet as W
import           System.IO

main = do
  statusBar <- spawnPipe "/usr/bin/xmobar /home/darek/.xmonad/xmobarrc"
  xmonad $ def {
    modMask = mod1Mask
    , borderWidth = 3
    , terminal = "terminator"
    , manageHook = manageDocks <+> (scratchpadManageHook $ (W.RationalRect 0.2 0.2 0.6 0.5))
                               <+> dynamicMasterHook <+> manageHook def
    , layoutHook = avoidStruts $ 
               tall ||| wide ||| full ||| three ||| stab ||| acc
    , handleEventHook = mconcat
                          [ docksEventHook
                          , handleEventHook def ]
    , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn statusBar
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
    , startupHook = do
          spawnOnce "nitrogen --restore"
          spawnOnce "compton &"
          spawnOnce "conky -d -c /home/darek/.conkyrc-stat"
          spawnOnce "setxkbmap -option caps:escape"
          spawnOnce "xautolock -time 10 -locker screenlock"
          spawnOnce "xset r rate 200 40"
          spawnOnce "xfce4-power-manager &"
  } `additionalKeys` [
                         ((mod1Mask, xK_grave), scratchpadSpawnActionCustom "st -n scratchpad")
                       -- , ((mod1Mask .|. controlMask, xK_l), spawn "screenlock")
                       , ((mod1Mask .|. controlMask, xK_l), spawn "blurlock")
                       , ((mod1Mask, xK_c), sendMessage (JumpToLayout "accordion"))
                       , ((mod1Mask, xK_f), sendMessage (JumpToLayout "full"))
                       , ((mod1Mask, xK_d), sendMessage (JumpToLayout "wide"))
                       , ((mod1Mask, xK_z), sendMessage MirrorShrink)
                       , ((mod1Mask, xK_a), sendMessage MirrorExpand)
                     ]
   `additionalKeysP` [
                       -- Move the focused window
                         ("M-<U>", withFocused (keysMoveWindow (0, -5)))
                       , ("M-<D>", withFocused (keysMoveWindow (0, 5)))
                       , ("M-<L>", withFocused (keysMoveWindow (-5, 0)))
                       , ("M-<R>", withFocused (keysMoveWindow (5, 0)))
                       -- Resize the focused window
                       , ("M-S-<U>", withFocused (keysResizeWindow (0, -5) (0, 0)))
                       , ("M-S-<D>", withFocused (keysResizeWindow (0, 5) (0, 0)))
                       , ("M-S-<R>", withFocused (keysResizeWindow (5, 0) (0, 0)))
                       , ("M-S-<L>", withFocused (keysResizeWindow (-5, 0) (0, 0)))
                       -- Go to the next / previous workspace
                       , ("M-C-<R>", nextWS)
                       , ("M-C-<L>", prevWS)
		       , ("M-o", incWindowSpacing 3)
		       , ("M-i", setScreenWindowSpacing 3)
		       , ("M-u", decWindowSpacing 3)
                     ]

tall   = renamed [Replace "tall"] $ spacing 3 $ ResizableTall 1 (3/100) (1/2) []
wide   = renamed [Replace "wide"] $ Mirror $ tall
full   = renamed [Replace "full"] $ spacing 3 $ Full
circle = renamed [Replace "circle"] $ circleSimpleDefaultResizable
stab   = renamed [Replace "tabbed"] $ simpleTabbed
acc    = renamed [Replace "accordion"] $ spacing 3 $ Accordion
three  = renamed [Replace "three"] $ spacing 3 $ ThreeColMid 1 (3/100) (1/2)
