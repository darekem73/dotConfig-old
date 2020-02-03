import           XMonad as X                         hiding ((|||))
import           XMonad.Util.SpawnOnce
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.DynamicHooks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.DynamicBars
import           XMonad.Hooks.SetWMName
import           XMonad.Layout.Accordion
import           XMonad.Layout.Fullscreen
import           XMonad.Layout.Grid
import           XMonad.Layout.LayoutCombinators
import           XMonad.Layout.NoBorders
import           XMonad.Layout.PerWorkspace
import           XMonad.Layout.Renamed
import           XMonad.Layout.Grid
import           XMonad.Layout.TwoPane
import           XMonad.Layout.ResizableTile     -- Resizable Horizontal border
import           XMonad.Layout.ThreeColumns
import           XMonad.Layout.StackTile
import           XMonad.Layout.Reflect
import           XMonad.Layout.MultiToggle
import           XMonad.Layout.Spacing           -- this makes smart space around windows
import           XMonad.Layout.AutoMaster
import           XMonad.Layout.WindowNavigation
import           XMonad.Layout.SimplestFloat
import           XMonad.Layout.Maximize
import           XMonad.Util.EZConfig
import           XMonad.Util.Run
import           XMonad.Util.Dmenu
import           XMonad.Util.NamedWindows (getName)
import           XMonad.Util.Scratchpad
import           XMonad.Actions.CycleWS
import           XMonad.Actions.WindowBringer
import           XMonad.Actions.GridSelect
import           XMonad.Actions.WithAll
import           XMonad.Actions.FloatKeys
import           XMonad.Actions.WorkspaceNames
import           XMonad.Actions.RotSlaves
import qualified XMonad.Actions.SwapWorkspaces as SWS
import qualified XMonad.StackSet as W
import           System.IO
import           System.Exit
import           Data.Maybe
import           Control.Monad

dchoice :: [String] -> [String] -> [X()] -> X()
dchoice args items actions = do
  result <- XMonad.Util.Dmenu.menuArgs "dmenu" args items
  when (True) (snd $ head [ element | element <- zip items actions, fst element == result ])

dconfirm args items action = do
  result <- XMonad.Util.Dmenu.menuArgs "dmenu" args items
  when (result == last items) action

barCreator :: DynamicStatusBar
barCreator (X.S sid) = spawnPipe $ "/usr/bin/xmobar --screen " ++ show sid ++ " /home/darek/.xmonad/xmobarrc"

barDestroyer :: DynamicStatusBarCleanup
barDestroyer = return ()

renameWS = do
  setCurrentWorkspaceName "test"
  -- renameWorkspace def

main = do
  -- statusBar <- spawnPipe "/usr/bin/xmobar /home/darek/.xmonad/xmobarrc"
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
    , layoutHook = mkToggle (single REFLECTX) $
                   mkToggle (single REFLECTY) $
                   avoidStruts $ 
                   tall ||| wide ||| dock ||| full ||| three ||| grid ||| acc ||| stack ||| autom ||| flt
    , handleEventHook = mconcat [
                          docksEventHook
                          , handleEventHook def
                          , dynStatusBarEventHook barCreator barDestroyer 
                        ]
    , workspaces = myWorkspaces
    , logHook = multiPPFormat dynamicLogString (def {
                           ppCurrent = xmobarColor "green" "" . wrap "[" "]"
                           -- , ppVisible = pad
                           -- ppCurrent = xmobarColor "green" "" . wrap "[" "]" . liftM (fromMaybe "") . getWorkspaceName
                           -- ppCurrent = xmobarColor "green" "" . wrap "[" "]" . liftM show . getWorkspaceName
                           -- ppCurrent = \tag -> getWorkspaceName tag >>= fromMaybe "" . liftX . xmobarColor "green" "" . wrap "[" "]"
                           -- ppCurrent = xmobarColor "green" "" . wrap "[" "]" . liftM show . getWorkspaceName
                           , ppUrgent  = xmobarColor "red" "yellow"
                           , ppTitle = xmobarColor "green" "" . shorten 50
                           }) (def)
--    , logHook = dynamicLogWithPP $ xmobarPP
--                        { ppOutput = hPutStrLn statusBar
--                        , ppTitle = xmobarColor "green" "" . shorten 50
--                        }
    , startupHook = do
          spawnOnce "nitrogen --restore"
          spawnOnce "compton &"
          spawnOnce "conky -d -c /home/darek/.conkyrc-stat"
          spawnOnce "setxkbmap -option caps:escape"
          --spawnOnce "xautolock -time 10 -locker screenlock"
          spawnOnce "xautolock -time 10 -locker slock"
          spawnOnce "synclient TapButton2=3 TapButton1=1"
          spawnOnce "synclient RightButtonAreaLeft=0 RightButtonAreaTop=0"
          spawnOnce "xset r rate 200 40"
          dynStatusBarStartup barCreator barDestroyer
          setWMName "LG3D"
  } `additionalKeys` ([
                         ((mod1Mask, xK_grave), scratchpadSpawnActionCustom "st -n scratchpad -e tmux")
                       , ((mod1Mask .|. controlMask, xK_l), spawn "slock")
                       , ((mod4Mask .|. shiftMask, xK_Return), spawn "st")
                       , ((mod4Mask, xK_Return), spawn "st")
                       , ((mod1Mask, xK_n), sendMessage (JumpToLayout "accordion"))
                       , ((mod1Mask, xK_c), sendMessage (JumpToLayout "dock"))
                       , ((mod1Mask, xK_f), sendMessage (JumpToLayout "full"))
                       , ((mod1Mask, xK_s), sendMessage (JumpToLayout "stack"))
                       , ((mod1Mask, xK_d), sendMessage (JumpToLayout "wide"))
                       , ((mod1Mask, xK_g), sendMessage (JumpToLayout "grid"))
                       , ((mod1Mask, xK_t), sendMessage (JumpToLayout "float"))
                       , ((mod1Mask, xK_z), sendMessage MirrorShrink)
                       , ((mod1Mask, xK_a), sendMessage MirrorExpand)
                       , ((mod1Mask, xK_b), sendMessage $ ToggleStruts)
                       , ((mod1Mask, xK_m), withFocused (sendMessage . maximizeRestore))
                       , ((mod1Mask .|. shiftMask, xK_r), renameWS)
                       -- mirror layout like spectrwm       
                       , ((mod1Mask .|. shiftMask, xK_backslash), sendMessage $ Toggle REFLECTX)
                       , ((mod1Mask, xK_backslash), sendMessage $ Toggle REFLECTY)
                       -- float window
                       , ((mod1Mask .|. shiftMask, xK_f), withFocused float)
                       -- unfloat all windows
                       , ((mod1Mask .|. shiftMask, xK_t), sinkAll)
                       -- inc/dec number of windows in master
                       , ((mod1Mask .|. shiftMask, xK_bracketleft), sendMessage $ IncMasterN 1)
                       , ((mod1Mask .|. shiftMask, xK_bracketright), sendMessage $ IncMasterN (-1))
                       -- rotate slave stack
                       , ((mod1Mask .|. shiftMask, xK_comma), rotSlavesDown)
                       , ((mod1Mask .|. shiftMask, xK_period), rotSlavesDown)
                       , ((mod1Mask, xK_comma), rotSlavesUp)
                       , ((mod1Mask, xK_period), rotSlavesUp)
                       , ((mod1Mask, xK_0), gotoMenuConfig WindowBringerConfig { menuCommand = "dmenu"
                                                                  , XMonad.Actions.WindowBringer.menuArgs = ["-p","Goto","-i","-l","10"]
                                                                  , windowTitler = decorateName
                                                                  })
                       , ((mod1Mask .|. shiftMask, xK_0), bringMenuConfig WindowBringerConfig { menuCommand = "dmenu"
                                                                  , XMonad.Actions.WindowBringer.menuArgs = ["-p","Bring","-i","-l","10"]
                                                                  , windowTitler = decorateName
                                                                  })
                       , ((mod1Mask, xK_p), spawn "dmenu_run -i") -- %! Launch dmenu
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
                     ++ [
                         --((mod1Mask .|. controlMask, k), windows $ SWS.swapWithCurrent i) | (i, k) <- zip myWorkspaces [xK_1 ..]
                         ((mod1Mask .|. controlMask, k), swapWithCurrent i) | (i, k) <- zip myWorkspaces [xK_1 ..]
                     ])
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
                                                                                , (spawn "sudo poweroff")])
                     ]
     where 
       helpCommand :: X ()
       helpCommand = spawn ("echo " ++ show help ++ " | xmessage -file -")
       decorateName :: X.WindowSpace -> Window -> X String
       decorateName ws w = do
               name <- show <$> getName w
	       -- current <- show <$> withWindowSet (pure . W.currentTag)
	       -- current <- withWindowSet (pure . W.currentTag)
               current <- gets (W.currentTag . windowset)
               -- return $ (if (read $ current) == W.tag ws then "*" else "") ++ "[" ++ W.tag ws ++ "] " ++ name
               return $ (if current == W.tag ws then "*" else "") ++ "[" ++ W.tag ws ++ "] " ++ name

tall   = renamed [Replace "tall"] $ maximize $ spacing 3 $ ResizableTall 1 (3/100) (1/2) []
wide   = renamed [Replace "wide"] $ Mirror $ tall
stack  = renamed [Replace "stack"] $ maximize $ spacing 3 $ StackTile 1 (3/100) (1/2)
full   = renamed [Replace "full"] $ noBorders $ Full
acc    = renamed [Replace "accordion"] $ maximize $ spacing 3 $ Accordion
three  = renamed [Replace "three"] $ maximize $ spacing 3 $ ThreeColMid 1 (3/100) (1/2)
grid   = renamed [Replace "grid"] $ maximize $ spacing 3 $ Grid
dock   = renamed [Replace "dock"] $ maximize $ spacing 3 $ TwoPane (3/100) (1/2)
autom  = renamed [Replace "autom"] $ maximize $ spacing 3 $ Mirror $ autoMaster 1 (1/100) Grid
flt    = renamed [Replace "float"] $ maximize $ simplestFloat 

myWorkspaces :: [WorkspaceId]
myWorkspaces = map show $ [1..9]

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
