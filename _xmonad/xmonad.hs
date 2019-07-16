import           XMonad as X                         hiding ((|||))
-- import qualified XMonad as X
import           XMonad.Util.SpawnOnce
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.DynamicHooks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Layout.Accordion
-- import           XMonad.Layout.DecorationMadness
import           XMonad.Layout.Fullscreen
import           XMonad.Layout.Grid
import           XMonad.Layout.LayoutCombinators
import           XMonad.Layout.NoBorders
import           XMonad.Layout.PerWorkspace
import           XMonad.Layout.Renamed
-- import           XMonad.Layout.Tabbed
import           XMonad.Layout.Grid
import           XMonad.Layout.TwoPane
-- import           XMonad.Layout.StackTile
-- import           XMonad.Layout.Gaps
import           XMonad.Layout.ResizableTile     -- Resizable Horizontal border
import           XMonad.Layout.ThreeColumns
-- import           XMonad.Layout.Dishes
import           XMonad.Layout.StackTile
-- import           XMonad.Layout.Simplest
-- import           XMonad.Layout.SimplestFloat
-- import           XMonad.Layout.SimpleFloat       -- simpleFloat, floating layout
-- import           XMonad.Layout.ToggleLayouts     -- Full window at any time
import           XMonad.Layout.Spacing           -- this makes smart space around windows
-- import           XMonad.Layout.Combo
import           XMonad.Layout.AutoMaster
import           XMonad.Layout.WindowNavigation
import           XMonad.Util.EZConfig
import           XMonad.Util.Run
import           XMonad.Util.Dmenu
import           XMonad.Util.NamedWindows (getName)
import           XMonad.Util.Scratchpad
import           XMonad.Actions.CycleWS
import           XMonad.Actions.WindowBringer
import           XMonad.Actions.GridSelect
-- import           XMonad.Prompt
-- import           XMonad.Prompt.Input
import           XMonad.Actions.WithAll
import           XMonad.Actions.FloatKeys
import qualified XMonad.StackSet as W
-- import           XMonad.Operations
import           System.IO
import           System.Exit
import           Control.Monad
-- import           Data.List

dchoice :: [String] -> [String] -> [X()] -> X()
dchoice args items actions = do
  result <- XMonad.Util.Dmenu.menuArgs "dmenu" args items
  -- when (result == last items) action
  when (True) (snd $ head [ element | element <- zip items actions, fst element == result ])

dconfirm args items action = do
  result <- XMonad.Util.Dmenu.menuArgs "dmenu" args items
  when (result == last items) action

main = do
  statusBar <- spawnPipe "/usr/bin/xmobar /home/darek/.xmonad/xmobarrc"
  xmonad $ docks $ def {
    modMask = mod1Mask
    , borderWidth = 2
    , terminal = "terminator"
    , manageHook = composeAll [
               manageDocks
               , scratchpadManageHook $ (W.RationalRect 0.2 0.2 0.6 0.5)
               , dynamicMasterHook
               , manageHook def
               ]
    , layoutHook = avoidStruts $ 
               tall ||| wide ||| dock ||| full ||| three ||| grid ||| acc ||| stack ||| autom
    , handleEventHook = mconcat [
                          docksEventHook
                          , handleEventHook def 
                        ]
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
          -- spawnOnce "xfce4-power-manager &"
  } `additionalKeys` [
                         ((mod1Mask, xK_grave), scratchpadSpawnActionCustom "st -n scratchpad")
                       -- , ((mod1Mask .|. controlMask, xK_l), spawn "screenlock")
                       -- , ((mod1Mask .|. controlMask, xK_l), spawn "blurlock")
                       , ((mod1Mask .|. controlMask, xK_l), spawn "screenlock")
                       , ((mod1Mask, xK_n), sendMessage (JumpToLayout "accordion"))
                       , ((mod1Mask, xK_c), sendMessage (JumpToLayout "dock"))
                       , ((mod1Mask, xK_f), sendMessage (JumpToLayout "full"))
                       , ((mod1Mask, xK_s), sendMessage (JumpToLayout "stack"))
                       , ((mod1Mask, xK_d), sendMessage (JumpToLayout "wide"))
                       , ((mod1Mask, xK_g), sendMessage (JumpToLayout "grid"))
                       , ((mod1Mask, xK_z), sendMessage MirrorShrink)
                       , ((mod1Mask, xK_a), sendMessage MirrorExpand)
                       , ((mod1Mask, xK_b), sendMessage $ ToggleStruts)
                       , ((mod1Mask .|. shiftMask, xK_f), withFocused float)
                       , ((mod1Mask .|. shiftMask, xK_t), sinkAll)
                       -- moving windows between layouts in combo mode
                       -- , ((mod1Mask, xK_bracketleft), sendMessage $ Move L)
                       -- , ((mod1Mask, xK_bracketright), sendMessage $ Move R)
                       -- increase decrease number of windows in master area (same as mod+, mod+._)
                       , ((mod1Mask .|. shiftMask, xK_bracketleft), sendMessage $ IncMasterN 1)
                       , ((mod1Mask .|. shiftMask, xK_bracketright), sendMessage $ IncMasterN (-1))
                       -- , ((mod1Mask, xK_0), goToSelected def)
                       -- , ((mod1Mask .|. shiftMask, xK_0), gotoMenu)
                       , ((mod1Mask, xK_0), gotoMenuConfig WindowBringerConfig { menuCommand = "dmenu"
                                                                  , XMonad.Actions.WindowBringer.menuArgs = ["-i","-l","10"]
                                                                  , windowTitler = decorateName
                                                                  })
                       , ((mod1Mask .|. shiftMask, xK_p), spawn "rofi -show drun -font 'Monospace 9' -theme solarized")
                       , ((mod1Mask, xK_equal), spawn "xbacklight -inc 10")
                       , ((mod1Mask, xK_minus), spawn "xbacklight -dec 10")
                       , ((mod1Mask .|. shiftMask, xK_equal), spawn "amixer -D pulse sset Master 10%+")
                       , ((mod1Mask .|. shiftMask, xK_minus), spawn "amixer -D pulse sset Master 10%-")
                       -- recompiling (possibly generate help here)
                       , ((mod1Mask, xK_q), spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi") -- %! Restart xmonad
                       , ((mod1Mask .|. shiftMask, xK_slash), helpCommand) -- %! Run xmessage with a summary of the default keybindings (useful for beginners)
                       -- repeat the binding for non-American layout keyboards
                       , ((mod1Mask, xK_question), helpCommand) -- %! Run xmessage with a summary of the default keybindings (useful for beginners)
                     ]
   `additionalKeysP` [
                       -- Move the focused window
                         ("M-<U>", withFocused (keysMoveWindow (0, -15)))
                       , ("M-<D>", withFocused (keysMoveWindow (0, 15)))
                       , ("M-<L>", withFocused (keysMoveWindow (-15, 0)))
                       , ("M-<R>", withFocused (keysMoveWindow (15, 0)))
                       -- Resize the focused window
                       , ("M-S-<U>", withFocused (keysResizeWindow (0, -15) (0, 0)))
                       , ("M-S-<D>", withFocused (keysResizeWindow (0, 15) (0, 0)))
                       , ("M-S-<R>", withFocused (keysResizeWindow (15, 0) (0, 0)))
                       , ("M-S-<L>", withFocused (keysResizeWindow (-15, 0) (0, 0)))
                       -- Go to the next / previous workspace
                       , ("M-C-<R>", nextWS)
                       , ("M-C-<L>", prevWS)
                       , ("M-o", incWindowSpacing 3)
                       , ("M-i", setScreenWindowSpacing 3)
                       , ("M-u", decWindowSpacing 3)
                       -- confirm quitting       
                       , ("M-S-q", dchoice ["-p","Exit?"] ["No","Yes","Shutdown"] [(spawn "")
                                                                                , (io exitSuccess)
                                                                                , (spawn "sudo -A shutdown now")])
                     ]
     where 
       helpCommand :: X ()
       helpCommand = spawn ("echo " ++ show help ++ " | xmessage -file -")
       decorateName :: X.WindowSpace -> Window -> X String
       decorateName ws w = do
               name <- show <$> getName w
               -- return $ name ++ " [" ++ W.tag ws ++ "]"
               return $ "[" ++ W.tag ws ++ "] " ++ name

tall   = renamed [Replace "tall"] $ spacing 3 $ ResizableTall 1 (3/100) (1/2) []
wide   = renamed [Replace "wide"] $ Mirror $ tall
-- dish   = renamed [Replace "dish"] $ spacing 3 $ Dishes 2 (1/8)
stack  = renamed [Replace "stack"] $ spacing 3 $ StackTile 1 (3/100) (1/2)
full   = renamed [Replace "full"] $ noBorders $ Full
-- circle = renamed [Replace "circle"] $ circleSimpleDefaultResizable
-- stab   = renamed [Replace "tabbed"] $ simpleTabbed
acc    = renamed [Replace "accordion"] $ spacing 3 $ Accordion
three  = renamed [Replace "three"] $ spacing 3 $ ThreeColMid 1 (3/100) (1/2)
grid   = renamed [Replace "grid"] $ spacing 3 $ Grid
dock   = renamed [Replace "dock"] $ spacing 3 $ TwoPane (3/100) (1/2)
-- combo  = renamed [Replace "combo"] $ windowNavigation (combineTwo (TwoPane (3/100) (1/2)) (Accordion) (Accordion))
autom  = renamed [Replace "autom"] $ spacing 3 $ Mirror $ autoMaster 1 (1/100) Grid

help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "",
    "-- Workspaces & screens",
    "mod-[1..9]         Switch to workSpace N",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging",
    "",
    "EOF"]
