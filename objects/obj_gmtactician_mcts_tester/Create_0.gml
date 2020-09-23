///@desc Asynchronous testing
var state = new TicTacToeState([
	-1, -1, -1,
	-1, -1, -1,
	1, -1, -1,
	0
]);
mcts = new TicTacToeMcts(state);
mctsDaemon = mcts.evaluateInBackground(0, 1000, infinity, function(_move) {
	var _correctMove = 4;
	assert_equal(_move, _correctMove, "MCTS asynchronous evaluate failed to find best move!");
	if (_move == _correctMove) {
		show_debug_message("MCTS asynchronous evaluate responded correctly!");
		layer_background_blend(layer_background_get_id(layer_get_id("Background")), c_green);
		instance_destroy();
	}
});
