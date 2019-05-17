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
-- import           XMonad.Actions.FloatKeys
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
               tall ||| wide ||| full ||| circle ||| stab ||| acc
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
                       , ((mod1Mask .|. controlMask, xK_l), spawn "screenlock")
                       , ((mod1Mask, xK_a), sendMessage (JumpToLayout "acc"))
                       , ((mod1Mask, xK_f), sendMessage (JumpToLayout "full"))
                     ]
   `additionalKeysP` [
                       -- Move the focused window
                       --  ("M-<R>", withFocused (keysMoveWindow (moveWD, 0)))
                       --, ("M-<L>", withFocused (keysMoveWindow (-moveWD, 0)))
                       --, ("M-<U>", withFocused (keysMoveWindow (0, -moveWD)))
                       --, ("M-<D>", withFocused (keysMoveWindow (0, moveWD)))
                       -- Resize the focused window
                       --, ("M-S-<R>", withFocused (keysResizeWindow (-resizeWD, resizeWD) (0.5, 0.5)))
                       --, ("M-S-<L>", withFocused (keysResizeWindow (resizeWD, resizeWD) (0.5, 0.5)))
                       -- Go to the next / previous workspace
                       ("M-C-<R>", nextWS)
                       , ("M-C-<L>", prevWS)
                     ]

tall   = renamed [Replace "tall"] $ spacing 3 $ Tall 1 0.03 0.5
wide   = renamed [Replace "wide"] $ spacing 3 $ Mirror $ tall
full   = renamed [Replace "full"] $ spacing 3 $ Full
circle = renamed [Replace "circle"] $ circleSimpleDefaultResizable
stab   = renamed [Replace "tabbed"] $ simpleTabbed
acc    = renamed [Replace "accordion"] $ spacing 3 $ Accordion
