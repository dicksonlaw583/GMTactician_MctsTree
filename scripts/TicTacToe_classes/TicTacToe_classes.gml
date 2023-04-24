/*
Current player: 9

 0 | 1 | 2
 --+---+---
 3 | 4 | 5 
 --+---+---
 6 | 7 | 8
 
 X=1, O=0, <empty>=-1
*/

///@func TicTacToeState(board)
///@param {Array<Real>} board A 10-entry 1D array (scheme above)
function TicTacToeState(board) constructor {
	self.board = board;
	
	///@func readMemo(memo)
	///@param {Array<Real>} memo The memo to load
	///@desc Read the memo into this state.
	static readMemo = function(memo) {
		array_copy(board, 0, memo, 0, 10);
	};
	
	///@func getMemo()
	///@return {Array<Real>}
	///@desc Return a memo for this state.
	static getMemo = function() {
		var memo = array_create(10, 0);
		array_copy(memo, 0, board, 0, 10);
		return memo;
	};
	
	///@func clone()
	///@return {Struct.TicTacToeState}
	///@desc Return a clone of this state.
	static clone = function() {
		return new TicTacToeState(getMemo());
	};
	
	///@func isFinal()
	///@return {Bool}
	///@desc Return whether this state is a finished endgame.
	static isFinal = function() {
		return !is_undefined(getPlayoutResult()[0]);
	};
	
	///@func getMoves()
	///@return {Array<Real>}
	///@desc Return an array of moves available from this state.
	static getMoves = function() {
		var moves = [];
		var ii = 0;
		for (var i = 0; i < 9; ++i) {
			if (board[i] < 0) {
				moves[ii++] = i;
			}
		}
		return moves;
	};
	
	///@func getCurrentPlayer()
	///@return {Real}
	///@desc Return the current player.
	static getCurrentPlayer = function() {
		return board[9];
	};
	
	///@func isLegal(move)
	///@param {Real} move The move to check
	///@return {Bool}
	///@desc Return whether playing the given move is legal.
	static isLegal = function(move) {
		return (move >= 0) && (move < 9) && (board[move] < 0);
	};
	
	///@func applyMove(move)
	///@param {Real} move The move to make
	///@desc Make the given move on this board state.
	static applyMove = function(move) {
		board[@move] = board[9];
		board[@9] = 1-board[9];
	};
	
	///@func getPlayoutResult()
	///@return {Array}
	///@desc Return a summary describing the current board state.
	///
	///pr[0] = 0 if O won, 1 if X won, 0.5 for draw
	///
	///pr[1..4] = The board positions involved if either player won
	static getPlayoutResult = function() {
		///Feather disable GM1045
		// Diagonals
		if (board[4] >= 0) {
			if (board[0] == board[4] && board[4] == board[8]) return [board[0], 0, 4, 8];
			if (board[2] == board[4] && board[4] == board[6]) return [board[2], 2, 4, 6];
		}
		
		// Rows
		for (var i = 0; i <= 6; i += 3) {
			if (board[i] >= 0 && board[i] == board[i+1] && board[i] == board[i+2]) return [board[i], i, i+1, i+2];
		}
		
		// Columns
		for (var i = 0; i <= 2; ++i) {
			if (board[i] >= 0 && board[i] == board[i+3] && board[i] == board[i+6]) return [board[i], i, i+3, i+6];
		}
		
		// Any empty square is not done
		for (var i = 0; i < 9; ++i) {
			if (board[i] < 0) return [undefined, undefined, undefined, undefined];
		}
		
		// Filled board is done
		return [0.5, undefined, undefined, undefined];
		///Feather enable GM1045
	};
}
