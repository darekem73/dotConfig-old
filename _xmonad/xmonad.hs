import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

-- NOTES: 0.10 works much better than 0.9, unfortunately distros mostly package 0.9 atm
-- xmobar and fullscreen flash vids (youtube): http://code.google.com/p/xmobar/issues/detail?id=41

-- TODO: would still like fullscreen flash vids to not crop and leave xmobar drawn
-- TODO: remove the red border when doing fullscreen? tried adding 'smartBorders' to the layoutHook but that didn't work
-- TODO: hook in TopicSpaces, start specific apps on specific workspaces

main = do
  nitrogen <- spawnPipe "nitrogen --restore"
  compton <- spawnPipe "compton &"
  conky <- spawnPipe "conky -d -c /home/darek/.conkyrc-stat"
  xset <- spawnPipe "xset r rate 200 40"
  statusBar <- spawnPipe "/usr/bin/xmobar /home/darek/.xmonad/xmobarrc"
  xmonad defaultConfig {
    modMask = mod1Mask, 
    terminal = "terminator",
-- if you are using xmonad 0.9, you can avoid web flash videos getting cropped in fullscreen like so:
-- manageHook = ( isFullscreen --> doFullFloat ) <+> manageDocks <+> manageHook defaultConfig,
-- (no longer needed in 0.10)
    manageHook = manageDocks <+> manageHook defaultConfig,
    layoutHook = avoidStruts $ layoutHook defaultConfig,
    handleEventHook = mconcat
                          [ docksEventHook
                          , handleEventHook defaultConfig ],
    logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn statusBar,
                          ppTitle = xmobarColor "green" "" . shorten 50
                        }
  }
