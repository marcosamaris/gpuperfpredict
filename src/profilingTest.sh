mkdir -p logs/test
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-metrics.csv

nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./vectorAdd/vectorAdd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/vectorAdd-events.csv


nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-metrics.csv

nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./dotProd/dotProd 33554432 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/dotProd-events.csv


nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-metrics.csv

nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./subSeqMax/subSeqMax 33554432 0 0 2> Temp; cat Temp | awk '{print 33554432"," $0}' | grep Tesla >>  ./logs/test/subSeqMax-events.csv


nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-metrics.csv

nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matMul/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matMul_gpu_uncoalesced-events.csv


nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matSum/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matSum/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matSum/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matSum/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-metrics.csv
nvprof --normalized-time-unit s --print-gpu-trace  --metrics all --csv   ./matSum/matMul_gpu_uncoalesced 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-metrics.csv

nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matSum/matrix_sum_normal 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matSum/matrix_sum_normal 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matSum/matrix_sum_normal 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matSum/matrix_sum_normal 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-events.csv
nvprof --normalized-time-unit s --print-gpu-trace  --events all --csv   ./matSum/matrix_sum_normal 1024 0 2> Temp; cat Temp | awk '{print 1024"," $0}' | grep Tesla >>  ./logs/test/matrix_sum_normal-events.csv

