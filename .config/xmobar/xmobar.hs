Config { 

   -- appearance
     font =         "xft:UbuntuMono Nerd Font Mono:regular:size=15:antialias=true:hinting=true"
   , bgColor =      "#373b3e"
   , fgColor =      "#86cecb"
   , position =     Static { xpos = 0, ypos = 0, width = 3840, height = 36 }
   , border =       BottomB
   , borderColor =  "#86cecb"
   , borderWidth = 3
   -- layout
   , sepChar =  "%"   -- delineator between plugin names and straight text
   , alignSep = "}{"  -- separator between left-right alignment
   , template = " %UnsafeStdinReader% }{ %multicpu% | %memory% | %dynnetwork% | %RJTT% | %date% "

   -- general behavior
   , lowerOnStart =     True    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = True    -- set the Override Redirect flag (Xlib)
   , pickBroadest =     False   -- choose widest display (multi-monitor)
   , persistent =       True    -- enable/disable hiding (True = disabled)

   -- plugins
   --   Numbers can be automatically colored according to their value. xmobar
   --   decides color based on a three-tier/two-cutoff system, controlled by
   --   command options:
   --     --Low sets the low cutoff
   --     --High sets the high cutoff
   --
   --     --low sets the color below --Low cutoff
   --     --normal sets the color between --Low and --High cutoffs
   --     --High sets the color above --High cutoff
   --
   --   The --template option controls how the plugin is displayed. Text
   --   color can be set by enclosing in <fc></fc> tags. For more details
   --   see http://projects.haskell.org/xmobar/#system-monitor-plugins.
   , commands = 

        -- weather monitor
        [ Run Weather "RJTT" [ "--template", "<skyCondition> | <fc=#b7eaee><tempC></fc>°C | <fc=#b7eaee><rh></fc>% | <fc=#b7eaee><pressure></fc>hPa"
                             ] 36000

        -- network activity monitor (dynamic interface resolution)
        , Run DynNetwork     [ "--template" , "<dev>: <tx>|<rx>"
                             , "--Low"      , "1000000"       -- units: B/s
                             , "--High"     , "10000000"       -- units: B/s
                             , "--low"      , "#47A5AE"
                             , "--normal"   , "darkorange"
                             , "--high"     , "#E12885"
                             , "-S"         , "True"
                             ] 20

        -- cpu activity monitor
        , Run MultiCpu       [ "--template" , "Cpu: <total>%"
                             , "--Low"      , "50"         -- units: %
                             , "--High"     , "85"         -- units: %
                             , "--low"      , "#47A5AE"
                             , "--normal"   , "darkorange"
                             , "--high"     , "#E12885"
                             ] 10

        -- cpu core temperature monitor
        , Run CoreTemp       [ "--template" , "Temp: <core0>°C|<core1>°C"
                             , "--Low"      , "70"        -- units: °C
                             , "--High"     , "80"        -- units: °C
                             , "--low"      , "#47A5AE"
                             , "--normal"   , "darkorange"
                             , "--high"     , "#E12885"
                             ] 50
                          
        -- memory usage monitor
        , Run Memory         [ "--template" ,"Mem: <usedratio>%"
                             , "--Low"      , "20"        -- units: %
                             , "--High"     , "90"        -- units: %
                             , "--low"      , "#47A5AE"
                             , "--normal"   , "darkorange"
                             , "--high"     , "#E12885"
                             ] 10

        -- battery monitor
        , Run Battery        [ "--template" , "Batt: <acstatus>"
                             , "--Low"      , "10"        -- units: %
                             , "--High"     , "80"        -- units: %
                             , "--low"      , "#E12885"
                             , "--normal"   , "darkorange"
                             , "--high"     , "#47A5AE"

                             , "--" -- battery specific options
                                       -- discharging status
                                       , "-o"	, "<left>% (<timeleft>)"
                                       -- AC "on" status
                                       , "-O"	, "<fc=#dAA520>Charging</fc>"
                                       -- charged status
                                       , "-i"	, "<fc=#006000>Charged</fc>"
                             ] 50

        -- time and date indicator 
        --   (%F = y-m-d date, %a = day of week, %T = h:m:s time)
        , Run Date           "<fc=#b7eaee>%F (%a) %T</fc>" "date" 10

        -- keyboard layout indicator
        , Run Kbd            [ ("us(dvorak)" , "<fc=#00008B>DV</fc>")
                             , ("us"         , "<fc=#8B0000>US</fc>")
                             ]
        , Run UnsafeStdinReader
        ]
   }
