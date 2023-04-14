///@func TicTacToeState(board)
///@param board A 10-entry 1D array (scheme below)
/**
Current player: 9

 0 | 1 | 2
 --+---+---
 3 | 4 | 5 
 --+---+---
 6 | 7 | 8
 
 X=1, O=0, <empty>=-1
**/
function TicTacToeState(board) constructor {
	self.board = board;
	
	static readMemo = function(memo) {
		array_copy(board, 0, memo, 0, 10);
	};
	
	static getMemo = function() {
		var memo = array_create(10);
		array_copy(memo, 0, board, 0, 10);
		return memo;
	};
	
	static clone = function() {
		return new TicTacToeState(getMemo());
	};
	
	static isFinal = function() {
		return !is_undefined(getPlayoutResult()[0]);
	};
	
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
	
	static getRandom = function() {
		show_error("Tic Tac Toe is not a game of chance.", true);
	};
	
	static getCurrentPlayer = function() {
		return board[9];
	};
	
	static isLegal = function(move) {
		return (move >= 0) && (move < 9) && (board[move] < 0);
	};
	
	static applyMove = function(move) {
		board[@move] = board[9];
		board[@9] = 1-board[9];
	};
	
	static getPlayoutResult = function() {
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
	};
}
