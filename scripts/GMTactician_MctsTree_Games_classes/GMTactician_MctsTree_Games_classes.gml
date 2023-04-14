///@class TicTacToeMcts(state)
///@param {Struct.TicTacToeState} state 
///@desc MCTS tree for the Tic-Tac-Toe game.
function TicTacToeMcts(state) : MctsTree(state) constructor {
	///@func interpret(pr, player)
	///@param {Array} pr The playout result to evaluate
	///@param {Real} player The player to view from
	///@return {Real}
	///@desc Return a reward value of the playout result from the player's perspective.
	static interpret = function(pr, player) {
		return lerp(1-pr[0], pr[0], player);
	};
}

///@class IntransitiveDiceMcts(state)
///@param {Struct.IntransitiveDiceState} state The root state to start from
///@desc MCTS tree for the Intransitive Dice game.
function IntransitiveDiceMcts(state) : MctsTree(state) constructor {
	///@func presample()
	///@return {Array<Array<Real>>}
	///@desc ///@desc Return an array of move-probability pairs for this game.
	static presample = function() {
		switch (state.picks[state.currentPlayer]) {
			case 0: return [[2, 1/3], [4, 1/3], [9, 1/3]];
			case 1: return [[1, 1/3], [6, 1/3], [8, 1/3]];
			case 2: return [[3, 1/3], [5, 1/3], [7, 1/3]];
		}
		show_error("Picked invalid die: " + string(state.picks[state.currentPlayer]), true);
	};
}
