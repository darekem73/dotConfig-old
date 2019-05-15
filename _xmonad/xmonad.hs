--
-- File     : ~/.xmonad/xmonad.hs
-- Author   : Yiannis Tsiouris (yiannist)
-- Desc     : A clean and well-documented xmonad configuration file (based on
--            the $HOME/.cabal/share/xmonad-0.10.1/man/xmonad.hs template file).
--
--            It uses:
--              * a ScratchPad (for a hidden terminal),
--              * an IM layout for Pidgin,
--              * a layout prompt (with auto-complete).
--
import           XMonad                          hiding ((|||))
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.DynamicLog
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
import           XMonad.Layout.Gaps
import           XMonad.Util.EZConfig
import           XMonad.Util.Run
import           XMonad.Util.EZConfig
import           System.IO

main = do
  nitrogen <- spawnPipe "nitrogen --restore"
  compton <- spawnPipe "compton &"
  conky <- spawnPipe "conky -d -c /home/darek/.conkyrc-stat"
  xset <- spawnPipe "xset r rate 200 40"
  statusBar <- spawnPipe "/usr/bin/xmobar /home/darek/.xmonad/xmobarrc"
  xmonad defaultConfig {
    modMask = mod1Mask
    , borderWidth = 1
    , terminal = "terminator"
    , manageHook = manageDocks <+> manageHook defaultConfig
    , layoutHook = avoidStruts $ smartBorders $ 
               tall ||| wide ||| full ||| circle ||| sTabbed ||| acc
    , handleEventHook = mconcat
                          [ docksEventHook
                          , handleEventHook defaultConfig ]
    , logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn statusBar
                        , ppTitle = xmobarColor "green" "" . shorten 50
                        }
  }

tall   = renamed [Replace "tall"] $ Tall 1 0.03 0.5
wide   = renamed [Replace "wide"] $ Mirror tall
full   = renamed [Replace "full"] $ Full
circle = renamed [Replace "circle"] $ circleSimpleDefaultResizable
sTabbed = renamed [Replace "tabbed"] $ simpleTabbed
acc = renamed [Replace "accordion"] $ Accordion

