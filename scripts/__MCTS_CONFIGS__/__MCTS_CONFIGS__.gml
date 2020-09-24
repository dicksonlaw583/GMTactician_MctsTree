/**
The number of times to sample a randomization outcome when expanding.
Applicable only to games with randomization.
**/
#macro MCTS_DEFAULT_PRESAMPLE_N 60

/**
Configurations for the background MCTS daemon.
- Minimum ticks/step: The minimum number of ticks to evaluate per step.
- Default ticks/step: The default number of ticks to evaluate per step.
- Congestion factor: If fps_real (native) or fps (HTML5) falls below this times room_speed, the daemon will enter congestion control to minimize screen lag.
- Congestion cut: The fraction (0-1) of the current ticks/step rate to reduce by when in congestion control.
- Slow start increment: The increase in the current ticks/step rate when not in congestion control.
**/
#macro MCTS_MIN_TICKS_PER_STEP 10
#macro MCTS_DEFAULT_TICKS_PER_STEP 100
#macro MCTS_NATIVE_CONGESTION_FACTOR 2
#macro MCTS_NATIVE_CONGESTION_CUT 0.3
#macro MCTS_NATIVE_SLOW_START_INCREMENT 30
#macro MCTS_HTML5_CONGESTION_FACTOR 0.8
#macro MCTS_HTML5_CONGESTION_CUT 0.5
#macro MCTS_HTML5_SLOW_START_INCREMENT 20
