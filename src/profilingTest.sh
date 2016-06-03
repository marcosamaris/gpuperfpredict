nvprof --normalized-time-unit s --print-gpu-trace  --csv   ./vectorAdd 268435456 0 2> Temp; cat Temp | awk '{print 268435456"," $0}' | tail -n +4 >>  ../logs/run_9/vectorAdd-traces.csv
