///@desc Keep ticking
if (is_struct(tree) && !ready) {
	// Use TCP Reno algorithm to adjust ticksPerStep
	var referenceFPS = (os_browser == browser_not_a_browser) ? fps_real : fps;
	if (referenceFPS < room_speed*congestionFactor) {
		ticksPerStep = max(ticksPerStep*(1-congestionCut), minTicksPerStep);
	} else {
		ticksPerStep += slowStartIncrement;
	}
	// Run ticks determined above until quota met or done
	var ticksThisStep = 0;
	do {
		donePlayouts += tree.evaluateTick();
	} until (++ticksThisStep >= ticksPerStep || donePlayouts >= maxPlayouts || (current_time-startTime) >= maxTime);
	progress = donePlayouts/maxPlayouts;
	// If done
	if (donePlayouts >= maxPlayouts || (current_time-startTime) >= maxTime) {
		// Show that I'm done
		ready = true;
		progress = 1;
		// If the callback is given, run it and self-destruct
		show_debug_message(tree.getRankedMoves());
		bestMove = tree.getBestMove();
		if (!is_undefined(callback)) {
			if (is_method(callback)) {
				callback(bestMove)
			} else {
				script_execute(callback, bestMove);
			}
			instance_destroy();
		}
	}
}
