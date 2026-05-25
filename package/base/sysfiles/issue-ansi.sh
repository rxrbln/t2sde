# --- T2-COPYRIGHT-BEGIN ---
# t2/package/*/sysfiles/issue-ansi.sh
# Copyright (C) 2021 - 2026 The T2 SDE Project
# SPDX-License-Identifier: GPL-2.0
# --- T2-COPYRIGHT-END ---

cat > etc/issue.ansi << EOT
[?25l[?7l[0m[33m[1m
                        //[37m[0m[1m
 [0m[31m[1mTTTTTTTTTTTTTTT[37m[0m[1m       [0m[33m[1m//[37m[0m[1m
 [0m[31m[1mTTTTTTTTTTTTTTT[37m[0m[1m      [0m[33m[1m//[37m[0m[1m [0m[31m[1m..::[37m[0m[1m  [0m[34m[1m:-:.[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m           [0m[33m[1m//[37m[0m[1m [0m[31m[1m.::.[37m[0m[1m    [0m[34m[1m.:-:[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m          [0m[33m[1m//[37m[0m[1m  [0m[31m[1m.:.[37m[0m[1m       [0m[34m[1m--[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m         [0m[33m[1m//[37m[0m[1m            [0m[34m[1m:-:[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m        [0m[33m[1m//[37m[0m[1m           [0m[34m[1m.:-:[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m       [0m[33m[1m//[37m[0m[1m           [0m[34m[1m:-:.[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m      [0m[33m[1m//[37m[0m[1m          [0m[34m[1m.--.[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m     [0m[33m[1m//[37m[0m[1m         [0m[34m[1m.:-:[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m    [0m[33m[1m//[37m[0m[1m          [0m[34m[1m...[37m[0m[1m
       [0m[34m[1mttt[37m[0m[1m   [0m[33m[1m//[37m[0m[1m
            [0m[33m[1m//[37m[0m[1m         [0m[33m[1m.:::::::::::.[37m[0m[1m
           [0m[33m[1m//[37m[0m[1m[0m
[10A[9999999D[39C[0m[1m[31m[1m\l[0m@[31m[1m\n[0m 
[39C[0m-------[0m 
[39C[0m[31m[1mOS[0m[0m:[0m $sdetxt[0m 
[39C[0m[31m[1mKernel[0m[0m:[0m \r[0m 
[39C[0m[31m[1mDate[0m[0m:[0m \d[0m 
[39C[0m[31m[1mTime[0m[0m:[0m \t[0m 
[39C[0m[31m[1mUsers[0m[0m:[0m \U online[0m 
[?25h[?7h


EOT
