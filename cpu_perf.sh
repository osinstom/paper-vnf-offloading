for ((i=0; i<40; i++)); do echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor; done
