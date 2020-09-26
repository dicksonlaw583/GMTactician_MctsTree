///@func MctsTree(state)
///@param state The State struct to root at
///@desc An MCTS Tree --- Developers should inherit off this and optionally configure the prefabs
function MctsTree(_state) constructor {
	root = new MctsNode(undefined, _state.getCurrentPlayer(), undefined); //MctsNode
	rootMemo = _state.getMemo(); //Memo
	state = _state.clone(); //State
	selectPath = []; //MctsNode[]
	isPlayingOut = false;
	pliesMax = 0;
	pliesLeft = 0;
	
	#region Evaluation
	///@func evaluate(maxPlies, maxPlayouts, <maxTime>)
	///@param {int} maxPlies Maximum number of plies per playout (0 for unlimited)
	///@param {int} maxPlayouts Maximum number of playouts to evaluate
	///@param {int} <maxTime> (Optional) Maximum number of milliseconds to take before returning. Default: No limit.
	///@desc Evaluate this MCTS tree for up to the given number of playouts. Return the number of playouts actually done.
	static evaluate = function(_maxPlies, _maxPlayouts, _maxTime) {
		pliesMax = _maxPlies;
		pliesLeft = pliesMax;
		if (is_undefined(_maxTime)) {
			_maxTime = infinity;
		}
		var _startTime = current_time;
		var _playouts = 0;
		do {
			_playouts += evaluateTick();
		} until (_playouts >= _maxPlayouts || (current_time-_startTime) >= _maxTime);
		return _playouts;
	};
	
	///@func evaluateTick()
	///@desc Make one playout ply or one expansion. Return true when a playout is just completed or a leaf node gets selected, false otherwise.
	static evaluateTick = function() {
		// Playout mode
		if (isPlayingOut) {
			// Choose a move and apply it
			var _chosenMove = is_undefined(state.getCurrentPlayer()) ? state.getRandom() : play();
			state.applyMove(_chosenMove);
			// Are we done?
			if (--pliesLeft == 0 || state.isFinal()) {
				// Backpropagate, stop playing
				_evaluateBackpropagate();
				state.readMemo(rootMemo);
				pliesLeft = pliesMax;
				isPlayingOut = false;
				return true;
			}
		}
		// Select/Expansion mode
		else {
			// Select
			_evaluateSelect();
			// Apply the moves
			var _pathSize = array_length(selectPath);
			for (var i = 1; i < _pathSize; ++i) {
				state.applyMove(selectPath[i].move);
			}
			var _pathTip = selectPath[_pathSize-1];
			// Is it final? (signified by empty children array)
			if (is_array(_pathTip.children) && array_length(_pathTip.children) == 0) {
				// Backpropagate, stop playing
				_evaluateBackpropagate();
				state.readMemo(rootMemo);
				return true;
			}
			// Otherwise
			else {
				// Set path tip's current player
				_pathTip.player = state.getCurrentPlayer();
				// Attempt to expand
				if (_evaluateExpand()) {
					// Expansion successful, go into playout mode
					isPlayingOut = true;
				}
				// Expanded nothing
				else {
					// Backpropagate, stop playing
					_evaluateBackpropagate();
					state.readMemo(rootMemo);
					return true;
				}
			}
		}
		return false;
	};
	
	///@func _evaluateSelect()
	///@desc The evaluation step of the MCTS cycle.
	static _evaluateSelect = function() {
		// Start the path with the root
		selectPath[@0] = root;
		var _currentNode = root;
		var ii = 1;
		// As long as the current node is expanded
		while (!is_undefined(_currentNode.children)) {
			// Don't continue expanding leaf nodes
			var _currentNodeChildren = _currentNode.children;
			var _currentNodeChildrenN = array_length(_currentNodeChildren);
			if (_currentNodeChildrenN == 0) break;
			// Append the selected node to the path (random weighted if randomizer to play, weighting strategy if standard player to play)
			var _selectedNode = is_undefined(_currentNode.player) ? roll(_currentNode) : select(_currentNode);
			selectPath[@ii++] = _selectedNode;
			// Move onto the selected node and keep going
			_currentNode = _selectedNode;
		}
		// Tamp down the path's size
		array_resize(selectPath, ii);
	};
	
	///@func _evaluateExpand()
	///@desc The expansion step of the MCTS cycle.
	static _evaluateExpand = function() {
		// Cap final nodes
		if (state.isFinal()) {
			selectPath[array_length(selectPath)-1].children = [];
			return false;
		}
		// Gather info needed to expand the last node of the path
		var _pathLength = array_length(selectPath);
		var _currentPlayer = state.getCurrentPlayer();
		var _lastNode = selectPath[_pathLength-1];
		var _moves = is_undefined(_currentPlayer) ? presample() : expand();
		var _movesN = array_length(_moves);
		if (_movesN == 0) return false;
		var _children = array_create(_movesN);
		// Add a child node to the last node for every move
		// Randomizer controlled: Presample
		if (is_undefined(_currentPlayer)) {
			for (var i = _movesN-1; i >= 0; --i) {
				_children[@i] = new MctsNode(_moves[i][0], _currentPlayer, undefined);
				_children[@i].weight = _moves[i][1];
			}
		}
		// Player controlled: Expand
		else {
			for (var i = _movesN-1; i >= 0; --i) {
				_children[@i] = new MctsNode(_moves[i], _currentPlayer, undefined);
			}
		}
		_lastNode.children = _children;
		// Add the first expanded node to the path
		var _addedNode = _lastNode.children[0];
		_addedNode.player = state.getCurrentPlayer();
		selectPath[@_pathLength] = _addedNode;
		// Report expansion OK
		return true;
	};
	
	///@func _evaluateBackpropagate()
	///@desc The backpropagation step of the MCTS cycle.
	static _evaluateBackpropagate = function() {
		// Interpret the results
		var _playoutResult = state.getPlayoutResult();
		// Start with the root and increment its visits
		var _parentNode = selectPath[0];
		++_parentNode.visits;
		// For each subsequent node in the path
		var _pathLength = array_length(selectPath);
		for (var i = 1; i < _pathLength; ++i) {
			// Increment its visits count
			var _node = selectPath[i];
			++_node.visits;
			// Update the node's weight if it is not a randomizer node
			if (!is_undefined(_node.lastPlayer)) {
				var _reward = interpret(_playoutResult, _node.lastPlayer);
				_node.reward += _reward;
				reweight(_node, _parentNode, _reward);
			}
		}
	};
	
	///@func evaluateInBackground(maxPlies, maxPlayouts, <maxTime>, <callback>)
	///@param {int} maxPlies Maximum number of plies per playout (0 for unlimited)
	///@param {int} maxPlayouts Maximum number of playouts to evaluate
	///@param {int|undefined} <maxTime> (Optional) Maximum number of milliseconds to take before returning. Default: No limit.
	///@param {method|undefined} <callback> (Optional) A method or script to run when the evaluation completes. It will be passed the best chosen move, and the daemon will self-destruct unless the method/script returns true.
	///@desc Evaluate this MCTS tree in the background. Return the instance ID of the daemon.
	static evaluateInBackground = function(_maxPlies, _maxPlayouts, _maxTime, _callback) {
		var _id;
		var _tree = self;
		if (is_undefined(_maxTime)) {
			_maxTime = infinity;
		}
		pliesMax = _maxPlies;
		pliesLeft = pliesMax;
		with (instance_create_depth(0, 0, 0, __obj_gmtactician_mcts_daemon__)) {
			tree = _tree;
			maxPlayouts = _maxPlayouts;
			maxTime = _maxTime;
			callback = _callback;
			_id = id;
		}
		return _id;
	};
	
	///@func evaluateReset()
	///@desc Reset the evaluation state back to original, clear the selection path, and stop the playout if any.
	static evaluateReset = function() {
		state.readMemo(rootMemo);
		pliesLeft = pliesMax;
		array_resize(selectPath, 0);
		isPlayingOut = false;
	};
	#endregion
	
	#region Picking / Making Moves
	///@func reroot(moves)
	///@param {Move[]} moves Array of moves to make next
	///@desc Re-root the tree to the state that results from making the given sequence of moves from the root state. Return whether some part of the subtree is still valid.
	static reroot = function(_moves) {
		evaluateReset();
		var _movesN = array_length(_moves);
		for (var i = 0; i < _movesN; ++i) {
			var _move = _moves[i];
			var _moveString = string(_move);
			state.applyMove(_move);
			if (!is_undefined(root)) {
				var _newRoot = undefined;
				var _oldRoot = root;
				var _oldRootChildren = root.children;
				if (is_array(_oldRootChildren)) {
					for (var j = array_length(_oldRootChildren)-1; j >= 0; --j) {
						var _oldRootChild = _oldRootChildren[j];
						if (string(_oldRootChild.move) == _moveString) {
							_newRoot = _oldRootChild;
						} else {
							delete _oldRootChild;
						}
					}
				}
				root = _newRoot;
				delete _oldRoot;
			}
		}
		// Recreate the memo
		rootMemo = state.getMemo();
		// Recreate the root if we're in unexplored territory
		if (is_undefined(root)) {
			root = [new MctsNode(undefined, state.getCurrentPlayer(), undefined)];
			return false;
		}
		// Otherwise we're still in known territory, done
		return true;
	};
	
	///@func _getBestChild(node)
	///@param {MctsNode} node
	///@desc Return the best child of the given node, in terms of visits.
	static _getBestChild = function(_node) {
		var _bestNode = undefined;
		var _children = _node.children;
		if (is_array(_children) && array_length(_children) > 0) {
			_bestNode = _children[0];
			var _bestVisits = _bestNode.visits;
			for (var i = array_length(_children)-1; i >= 1; --i) {
				var _currentNode = _children[i];
				var _currentVisits = _currentNode.visits;
				if (_currentVisits > _bestVisits) {
					_bestNode = _currentNode;
					_bestVisits = _currentVisits;
				}
			}
		}
		return _bestNode;
	}
	
	///@func getBestMove()
	///@desc Return the move that the MCTS tree thinks is the best (i.e. most visited).
	static getBestMove = function() {
		var _bestNode = _getBestChild(root);
		return is_undefined(_bestNode) ? undefined : _bestNode.move;
	};
	
	///@func getBestMoveSequence(<n>)
	///@param {int|undefined} <n> (Optional) Maximum number of moves after the root state to read
	///@desc Return an array of moves in sequence that the MCTS tree believes is optimal for all players.
	static getBestMoveSequence = function(_n) {
		if (is_undefined(_n)) {
			_n = infinity;
		}
		var _sequence = [];
		var _currentNode = root;
		var ii = 0;
		while (_n--) {
			var _bestNode = _getBestChild(_currentNode);
			if (is_undefined(_bestNode)) return _sequence;
			_sequence[@ii++] = _bestNode.move;
			_currentNode = _bestNode;
		}
		return _sequence;
	};
	
	///@func getRankedMoves(<n>)
	///@param {int|undefined} <n> (Optional) Maximum number of different moves to consider
	///@desc Return an array of moves, ranked top-to-bottom by how good the MCTS tree thinks it is (i.e. number of visits)
	static getRankedMoves = function(_n) {
		var _children = root.children;
		if (is_undefined(_children)) return [];
		var _childrenN = array_length(_children);
		if (is_undefined(_n)) {
			_n = _childrenN;
		}
		var _rankings = array_create(_n);
		var pq = ds_priority_create();
		for (var i = _childrenN-1; i >= 0; --i) {
			var _child = _children[i];
			ds_priority_add(pq, _child.move, _child.visits);
		}
		for (var i = 0; i < _n; ++i) {
			_rankings[@i] = ds_priority_delete_max(pq);
		}
		ds_priority_destroy(pq);
		return _rankings;
	};
	
	///@func getRankedMovesVerbose(<n>)
	///@param {int|undefined} <n> (Optional) Maximum number of different moves to consider
	///@desc Return a 2D array of moves and associated properties; each row is [<move>, <number of visits>, <equity>, <weight>]
	static getRankedMovesVerbose = function(_n) {
		var _children = root.children;
		if (is_undefined(_children)) return [];
		var _childrenN = array_length(_children);
		if (is_undefined(_n)) {
			_n = _childrenN;
		}
		var _rankings = array_create(_n);
		var pq = ds_priority_create();
		for (var i = _childrenN-1; i >= 0; --i) {
			var _child = _children[i];
			ds_priority_add(pq, [_child.move, _child.visits, (_child.visits) ? (_child.reward/_child.visits) : 0, _child.weight], _child.visits);
		}
		for (var i = 0; i < _n; ++i) {
			_rankings[@i] = ds_priority_delete_max(pq);
		}
		ds_priority_destroy(pq);
		return _rankings;
	};
	#endregion
	
	#region User configurables (can leave as-is, override or set to an alternative prefab
	
	///@func selectDefault(node)
	///@param {MctsNode} node The node to pick children from
	///@desc Return the child node with the highest weight.
	static selectDefault = function(_node) {
		// Find the node with an undefined weight or the greatest weight of all children
		var _children = _node.children;
		var _childrenCount = array_length(_children);
		var _selectedNode = _children[_childrenCount-1];
		var _selectedNodeWeight = _selectedNode.weight;
		if (is_undefined(_selectedNodeWeight)) return _selectedNode;
		for (var i = _childrenCount-2; i >= 0; --i) {
			var _currentNode = _children[i];
			var _currentNodeWeight = _currentNode.weight;
			if (is_undefined(_currentNodeWeight)) return _currentNode;
			if (_currentNodeWeight > _selectedNodeWeight) {
				_selectedNode = _currentNode;
				_selectedNodeWeight = _currentNodeWeight;
			}
		}
		return _selectedNode;
	};
	static select = selectDefault;
	
	///@func rollDefault(randomizerNode)
	///@param {MctsNode} randomizerNode MctsNode with player=undefined
	///@desc Randomly select a child node, biased according to their weights
	static rollDefault = function(_node) {
		var _rand = random(1);
		var _currentNodeChildren = _node.children;
		var _selectedNode = undefined;
		for (var i = array_length(_currentNodeChildren)-1; i >= 0; --i) {
			_selectedNode = _currentNodeChildren[i];
			_rand -= _selectedNode.weight;
			if (_rand <= 0) break;
		}
		return _selectedNode;
	};
	static roll = rollDefault;
	
	///@func expandDefault()
	///@desc Return an array of moves to explore from the current internal state.
	static expandDefault = function() {
		return state.getMoves();
	};
	static expand = expandDefault;
	
	///@func playDefault()
	///@desc Choose a random move on the current internal state.
	static playDefault = function() {
		var _moves = state.getMoves();
		return _moves[irandom(array_length(_moves)-1)];
	};
	static play = playDefault;
	
	///@func interpretDefault(playoutResult, player)
	///@param {PlayoutResult} playoutResult The result of the playout
	///@param {Player} player The player as whom to evaluate the result
	///@desc Return a numeric reward from the perspective of the specified player.
	static interpretDefault = function(_playoutResult, _player) {
		return lerp(1-_playoutResult, _playoutResult, _player);
	};
	static interpret = interpretDefault;
	
	///@func reweightDefault(@node, parent, reward)
	///@param {MctsNode} @node The node to change the weight of
	///@param {MctsNode} parent The node's parent
	///@param {real} reward The incoming reward value to add
	///@desc Update the given node's weight, given the incoming reward
	static reweightDefault = function(_node, _parent, _reward) {
		_node.weight = _node.reward/_node.visits + sqrt(2*ln(_parent.visits+1)/_node.visits);
	};
	static reweight = reweightDefault;
	
	///@func presampleDefault()
	///@desc Run state.getRandom() settings.presampleN times, then return [Move m, real weight][]
	static presampleDefault = function() {
		// Set up accumulators
		var countMap = ds_map_create();
		var _moves = [];
		var _moveStrings = [];
		var _movesN = 0;
		// Sample settings.presampleN times
		repeat (settings.presampleN) {
			// Get a random move
			var _move = state.getRandom();
			var _moveString = string(_move);
			// Log it
			if (ds_map_exists(countMap, _moveString)) {
				countMap[? _moveString] += 1;
			} else {
				countMap[? _moveString] = 1;
				_moveStrings[@_movesN] = _moveString;
				_moves[@_movesN] = _move;
				++_movesN;
			}
		}
		// Generate the result
		var _results = array_create(_movesN);
		for (var i = _movesN-1; i >= 0; --i) {
			_results[@i] = [_moves[i], countMap[? _moveStrings[i]]/settings.presampleN];
		}
		ds_map_destroy(countMap);
		return _results;
	};
	static presample = presampleDefault;
	
	settings = {
		presampleN: MCTS_DEFAULT_PRESAMPLE_N
	};
	#endregion
	
	#region Alternative Prefabs
	///@func selectNoisy(node)
	///@param {MctsNode} node The node to pick children from
	///@desc Choose a random child settings.selectNoise amount of the time (should be in [0, 1]), and the highest weighted child the rest of the time.
	static selectNoisy = function(_node) {
		var _nodeChildren = _node.children;
		if (is_undefined(_nodeChildren)) return undefined;
		var _nodeChildrenN = array_length(_nodeChildren)-1;
		if (random(1) < settings.selectNoise) {
			return _nodeChildren[irandom(_nodeChildrenN)];
		}
		var _chosenNode = _nodeChildren[0];
		var _chosenWeight = _chosenNode.weight;
		if (is_undefined(_chosenWeight)) return _chosenNode;
		
		var _currentNode, _currentWeight;
		var i = 0;
		while (i++ != _nodeChildrenN) {
			_currentNode = _nodeChildren[i];
			_currentWeight = _currentNode.weight;
			if (is_undefined(_currentWeight)) return _currentNode;
			if (_currentWeight > _chosenWeight) {
				_chosenNode = _currentNode;
				_chosenWeight = _currentWeight;
			}
		}
		return _chosenNode;
	};
	
	///@func rollUniform(node)
	///@param {MctsNode} node The node to pick random children from
	///@desc Choose each children at uniform distribution, ignore their weights
	static rollUniform = function(_node) {
		var _nodeChildren = _node.children;
		var _nodeChildrenN = array_length(_nodeChildren);
		return _nodeChildren(irandom(_nodeChildrenN-1)) ;
	};
	
	///@func expandShuffled()
	///@desc Same as the standard expand, but the array is shuffled. This helps alleviate move biases when evaluating with few playouts.
	static expandShuffled = function() {
		var _moves = state.getMoves();
		for (var i = array_length(_moves)-1; i >= 1; --i) {
			var j = irandom(i);
			var _temp = _moves[i];
			_moves[@i] = _moves[j];
			_moves[@j] = _temp;
		}
		return _moves;
	};
	
	///@func expandFrac()
	///@desc Return settings.expandFrac of the array of moves to explore. Should be between 0-1.
	static expandFrac = function() {
		var _moves = state.getMoves();
		var _movesN = array_length(_moves);
		for (var i = _movesN-1; i >= 1; --i) {
			var j = irandom(i);
			var _temp = _moves[i];
			_moves[@i] = _moves[j];
			_moves[@j] = _temp;
		}
		array_resize(_moves, ceil(settings.expandFrac*_movesN));
		return _moves;
	};
	
	///@func playNth()
	///@desc Always use the (settings.playNth)-th move given by state.getMoves() (or the closest to it if there aren't enough moves).
	static playNth = function() {
		var _moves = state.getMoves();
		return _moves[min(array_length(_moves)-1, settings.playNth-1)];
	};
	
	///@func playNthBest()
	///@desc Always use the (settings.playNthBest)-th move given by state.getMoves() (or the closest to it if there aren't enough moves), ranked according to settings.stateHeuristic(resultState) descending.
	static playNthBest = function() {
		var _moves = state.getMoves();
		var _movesN = array_length(_moves);
		var _tempState = state.clone();
		var _tempStateMemo = _tempState.memo();
		
		var pq = ds_priority_create();
		for (var i = _movesN-1; i >= 0; --i) {
			var _currentMove = _moves[i];
			_tempState.applyMove(_currentMove);
			ds_priority_add(pq, _currentMove, settings.stateHeuristic(_tempState));
			_tempState.readMemo(_tempStateMemo);
		}
		
		var _chosenMove;
		if (settings.playNthBest >= _movesN) {
			_chosenMove = ds_priority_find_min(pq);
		} else {
			repeat (settings.playNthBest) {
				_chosenMove = ds_priority_delete_max(pq);
			}
		}
		ds_priority_destroy(pq);
		return _chosenMove;
	};
	
	///@func reweightUct(@node, parent, reward)
	///@param {MctsNode} @node The node to change the weight of
	///@param {MctsNode} parent The node's parent
	///@param {real} reward The incoming reward value to add
	///@desc Update the given node's UCT weight and cumulative reward, given the incoming reward and settings.uctC
	static reweightUct = function(_node, _parent, _reward) {
		_node.weight = _node.reward/_node.visits + settings.uctC*sqrt(ln(_parent.visits+1)/_node.visits);
	};
	#endregion
}

///@func MctsNode(move, lastPlayer, player)
///@param {Move} move The Move this node represents
///@param {Player|undefined} lastPlayer The preceding player
///@param {Player|undefined} player The current player
///@desc An MCTS Tree Node
function MctsNode(_move, _lastPlayer, _player) constructor {
	move = _move;
	lastPlayer = _lastPlayer;
	player = _player;
	weight = undefined;
	reward = 0;
	visits = 0;
	children = undefined;
	
	static toString = function() {
		return string({
			move: move,
			lastPlayer: lastPlayer,
			player: player,
			weight: weight,
			reward: reward,
			visits: visits,
			children: is_array(children) ? array_length(children) : 0,
			equity: visits ? reward/visits : undefined,
		});
	};
}
