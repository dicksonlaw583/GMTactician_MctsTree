/*
Simple game where two players pick one of three dice, then rolls them, highest wins.

Die 0: 2, 2, 4, 4, 9, 9
Die 1: 1, 1, 6, 6, 8, 8
Die 2: 3, 3, 5, 5, 7, 7

Best strategy for second player: 0 to beat 1, 1 to beat 2, 2 to beat 0
Source: https://en.wikipedia.org/wiki/Nontransitive_dice#Example
*/

///@func IntransitiveDiceState(player)
///@param player (Optional) The first player to play (chosen at random if not given)
///@desc A state for the intransitive dice game described in https://en.wikipedia.org/wiki/Nontransitive_dice#Example
function IntransitiveDiceState(player=choose(0, 1)) constructor {
	currentPlayer = player;
	phase = 0; //0=picking, 1=rolling, 2=done
	picks = [undefined, undefined]; //0,1,2
	rolls = [undefined, undefined];
	
	///@func readMemo(memo)
	///@param {Array<Any>} memo The memo to load
	///@desc Read the memo into this state.
	static readMemo = function(memo) {
		currentPlayer = memo[0];
		phase = memo[1];
		array_copy(picks, 0, memo, 2, 2);
		array_copy(rolls, 0, memo, 4, 2);
	};
	
	///@func getMemo()
	///@return {Array<Any>}
	///@desc Return a memo for this state.
	static getMemo = function() {
		var memo = [currentPlayer, phase, undefined, undefined, undefined, undefined];
		array_copy(memo, 2, picks, 0, 2);
		array_copy(memo, 4, rolls, 0, 2);
		return memo;
	};
	
	///@func clone()
	///@return {Struct.IntransitiveDiceState}
	///@desc Return a clone of this state.
	static clone = function() {
		var cloned = new IntransitiveDiceState(currentPlayer);
		cloned.phase = phase;
		array_copy(cloned.picks, 0, picks, 0, 2);
		array_copy(cloned.rolls, 0, rolls, 0, 2);
		return cloned;
	};
	
	///@func isFinal()
	///@return {Bool}
	///@desc Return whether this state is a finished endgame.
	static isFinal = function() {
		return phase == 2;
	};
	
	///@func getMoves()
	///@return {Array<Real>}
	///@desc Return an array of moves available from this state.
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
	
	///@func getRandom()
	///@return {Real}
	///@desc Return a random roll for the current player.
	static getRandom = function() {
		switch (picks[currentPlayer]) {
			case 0: return choose(2, 4, 9);
			case 1: return choose(1, 6, 8);
			case 2: return choose(3, 5, 7);
		}
		show_error("Picked invalid die: " + string(picks[currentPlayer]), true);
	};
	
	///@func getCurrentPlayer()
	///@return {Real,Undefined}
	///@desc Return the current player (undefined=randomizer).
	static getCurrentPlayer = function() {
		return (phase == 1) ? undefined : currentPlayer;
	};
	
	///@func isLegal(move)
	///@param {Real} move The move to check
	///@return {Bool}
	///@desc Return whether playing the given move is legal.
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
	
	///@func applyMove(move)
	///@param {Real} move The move to make
	///@desc Make the given move on this board state.
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
	
	///@func getPlayoutResult()
	///@return {Real}
	///@desc Return a result describing the current board state.
	///
	///0 if player 0 won, 1 if player 1 won, 0.5 if draw or unfinished
	static getPlayoutResult = function() {
		return (phase == 2) ? ((rolls[0] > rolls[1]) ? 0 : 1) : 0.5;
	};
}
