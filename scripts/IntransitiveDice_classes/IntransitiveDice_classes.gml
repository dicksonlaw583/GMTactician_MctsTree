/**
Simple game where two players pick one of three dice, then rolls them, highest wins.

Die 0: 2, 2, 4, 4, 9, 9
Die 1: 1, 1, 6, 6, 8, 8
Die 2: 3, 3, 5, 5, 7, 7

Best strategy for second player: 0 to beat 1, 1 to beat 2, 2 to beat 0
Source: https://en.wikipedia.org/wiki/Nontransitive_dice#Example
*/

///@func IntransitiveDiceState(<player>)
///@param <player> (Optional) The first player to play (chosen at random if not given)
///@desc A state for the intransitive dice game described above
function IntransitiveDiceState(_firstPlayer) constructor {
	currentPlayer = is_undefined(_firstPlayer) ? choose(0, 1) : _firstPlayer;
	phase = 0; //0=picking, 1=rolling, 2=done
	picks = [undefined, undefined]; //0,1,2
	rolls = [undefined, undefined];
	
	static readMemo = function(memo) {
		currentPlayer = memo[0];
		phase = memo[1];
		array_copy(picks, 0, memo, 2, 2);
		array_copy(rolls, 0, memo, 4, 2);
	};
	
	static getMemo = function() {
		var memo = [currentPlayer, phase, undefined, undefined, undefined, undefined];
		array_copy(memo, 2, picks, 0, 2);
		array_copy(memo, 4, rolls, 0, 2);
		return memo;
	};
	
	static clone = function() {
		var cloned = new IntransitiveDiceState(currentPlayer);
		cloned.phase = phase;
		array_copy(cloned.picks, 0, picks, 0, 2);
		array_copy(cloned.rolls, 0, rolls, 0, 2);
		return cloned;
	};
	
	static isFinal = function() {
		return phase == 2;
	};
	
	static getMoves = function() {
		var moves = [];
		var ii = 0;
		for (var i = 0; i < 3; ++i) {
			if (picks[0] != i && picks[1] != i) {
				moves[ii++] = i;
			}
		}
		return moves;
	};
	
	static getRandom = function() {
		switch (picks[currentPlayer]) {
			case 0: return choose(2, 4, 9);
			case 1: return choose(1, 6, 8);
			case 2: return choose(3, 5, 7);
		}
		show_error("Picked invalid die: " + string(picks[currentPlayer]), true);
	};
	
	static getCurrentPlayer = function() {
		return (phase == 1) ? undefined : currentPlayer;
	};
	
	static isLegal = function(move) {
		switch (phase) {
			case 0: return (is_undefined(picks[0]) || move != picks[0]) && (is_undefined(picks[1]) || move != picks[1]);
			case 1: switch (picks[currentPlayer]) {
				case 0: return move == 2 || move == 4 || move == 9;
				case 1: return move == 1 || move == 6 || move == 8;
				case 2: return move == 3 || move == 5 || move == 7;
			}
		}
		return false;
	};
	
	static applyMove = function(move) {
		var otherPlayer = 1-currentPlayer;
		switch (phase) {
			case 0:
				picks[currentPlayer] = move;
				if (!is_undefined(picks[otherPlayer])) {
					phase = 1;
				}
				break;
			case 1:
				rolls[currentPlayer] = move;
				if (!is_undefined(rolls[otherPlayer])) {
					phase = 2;
				}
				break;
		}
		currentPlayer = otherPlayer;
	};
	
	static getPlayoutResult = function() {
		return (phase == 2) ? ((rolls[0] > rolls[1]) ? 0 : 1) : 0.5;
	};
}
