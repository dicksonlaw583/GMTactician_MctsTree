///@func gmta_mcts_test_all()
function gmta_mcts_test_all() {
	global.__test_fails__ = 0;
	var timeA = current_time;
	
	/** vv Place tests here vv **/
	// Synchronous evaluate Tic-Tac-Toe
	var state = new TicTacToeState([
		0, -1, -1,
		-1, -1, -1,
		-1, -1, -1,
		1
	]);
	var mcts = new TicTacToeMcts(state);
	mcts.evaluate(0, 500);
	assert_equal(mcts.getBestMove(), 4, "MCTS synchronous evaluate failed to find best move for Tic-Tac-Toe!");
	delete mcts;
	
	// Synchronous evaluate Intransitive Dice 0
	var state = new IntransitiveDiceState(0);
	state.applyMove(0);
	var mcts = new IntransitiveDiceMcts(state);
	mcts.evaluate(0, 600);
	assert_equal(mcts.getBestMove(), 2, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 0!");
	delete mcts;
	
	// Synchronous evaluate Intransitive Dice 1
	var state = new IntransitiveDiceState(1);
	state.applyMove(1);
	var mcts = new IntransitiveDiceMcts(state);
	mcts.evaluate(0, 600);
	assert_equal(mcts.getBestMove(), 0, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 1!");
	delete mcts;
	
	// Synchronous evaluate Intransitive Dice 2
	var state = new IntransitiveDiceState(0);
	state.applyMove(2);
	var mcts = new IntransitiveDiceMcts(state);
	mcts.evaluate(0, 600);
	assert_equal(mcts.getBestMove(), 1, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 2!");
	delete mcts;
	
	// Asynchronous evaluate
	var state = new TicTacToeState([
		-1, -1, -1,
		-1, -1, -1,
		1, -1, -1,
		0
	]);
	var mcts = new TicTacToeMcts(state);
	mcts.evaluateInBackground(0, 1000, infinity, function(_move) {
		var _correctMove = 4;
		assert_equal(_move, _correctMove, "MCTS asynchronous evaluate failed to find best move!");
		if (_move == _correctMove) {
			show_debug_message("MCTS asynchronous evaluate responded correctly!");
			layer_background_blend(layer_background_get_id(layer_get_id("Background")), c_green);
			instance_destroy();
		}
	});
	/** ^^ Place tests here ^^ **/
	
	var timeB = current_time;
	show_debug_message("MCTS tests completed in " + string(timeB-timeA) + "ms.");
	return global.__test_fails__;
}