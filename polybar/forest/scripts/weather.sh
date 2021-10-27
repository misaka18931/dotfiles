#!/bin/bash
# get local weather report in xmobar using wttr.in

str=$(curl -s "wttr.in/wuhan?format=j1" | jq -r '(.current_condition[] |
  .temp_C,
  .FeelsLikeC,
  .humidity,
  .pressure,
  .winddir16Point,
  .windspeedKmph,
  (.weatherDesc[] | .value)),
  (.weather[0] | .mintempC, .maxtempC)'  | paste -sd\| -)

IFS=\| read t t_feel hu p w_dir w_speed desc min max < <(echo $str)

printf "%%{F#86cecb}%%{F-} %b(%b)糖 %b/%b糖  %%{F#86cecb}%%{F-} %b%%  %%{F#86cecb}%%{F-} %dhPa  %%{F#86cecb}煮%%{F-} %b %bKmph  %%{F#86cecb}%%{F-}  %b\n" "$t" "$t_feel" "$min" "$max" "$hu" "$p" "$w_dir" "$w_speed" "$desc"
unset str t t_feel hu p w_dir w_speed desc

