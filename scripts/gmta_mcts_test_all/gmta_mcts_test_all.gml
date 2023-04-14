///@func gmta_mcts_test_all()
function gmta_mcts_test_all() {
	global.__test_fails__ = 0;
	var timeA = current_time;
	var state, mcts;
	
	/** vv Place tests here vv **/
	// Synchronous evaluate Tic-Tac-Toe
	state = new TicTacToeState([
		0, -1, -1,
		-1, -1, -1,
		-1, -1, -1,
		1
	]);
	mcts = new TicTacToeMcts(state);
	mcts.evaluate(0, 500);
	assert_equal(mcts.getBestMove(), 4, "MCTS synchronous evaluate failed to find best move for Tic-Tac-Toe!");
	delete mcts;
	
	// Synchronous evaluate Intransitive Dice 0
	state = new IntransitiveDiceState(0);
	state.applyMove(0);
	mcts = new IntransitiveDiceMcts(state);
	mcts.evaluate(0, 600);
	assert_equal(mcts.getBestMove(), 2, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 0!");
	delete mcts;
	
	// Synchronous evaluate Intransitive Dice 1
	state = new IntransitiveDiceState(1);
	state.applyMove(1);
	mcts = new IntransitiveDiceMcts(state);
	mcts.evaluate(0, 600);
	assert_equal(mcts.getBestMove(), 0, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 1!");
	delete mcts;
	
	// Synchronous evaluate Intransitive Dice 2
	state = new IntransitiveDiceState(0);
	state.applyMove(2);
	mcts = new IntransitiveDiceMcts(state);
	mcts.evaluate(0, 600);
	assert_equal(mcts.getBestMove(), 1, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 2!");
	delete mcts;
	/** ^^ Place tests here ^^ **/
	
	var timeB = current_time;
	show_debug_message("MCTS tests completed in " + string(timeB-timeA) + "ms.");
	return global.__test_fails__ == 0;
}