function TicTacToeMcts(_state) : MctsTree(_state) constructor {
	static interpret = function(_pr, _player) {
		return lerp(1-_pr[0], _pr[0], _player);
	};
}

function IntransitiveDiceMcts(_state) : MctsTree(_state) constructor {
	static presample = function() {
		switch (state.picks[state.currentPlayer]) {
			case 0: return [[2, 1/3], [4, 1/3], [9, 1/3]];
			case 1: return [[1, 1/3], [6, 1/3], [8, 1/3]];
			case 2: return [[3, 1/3], [5, 1/3], [7, 1/3]];
		}
		show_error("Picked invalid die: " + string(state.picks[state.currentPlayer]), true);
	};
}
