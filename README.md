# GMTactician Collection: MCTS Tree Devkit

## Introduction

This library provides a basic framework for implementing the [Monte Carlo Tree Search](https://en.wikipedia.org/wiki/Monte_Carlo_tree_search) (MCTS) algorithm. Both synchronous and asynchronous evaluation are supported, and you can develop a basic AI off little more than the basic rules of your game. For many simple games, the resulting AI can be quite powerful, yet also easy to tune for players of various levels of skill.

## Requirements

- GameMaker Studio 2.3.0 or higher
    - Known issue: This library does not work on the HTML5 export for Runtime 2.3.0.401 due to a bug in the way it handles passed functions/methods.

## Installation

Get the asset package and the associated documentation from [the releases page](https://github.com/dicksonlaw583/GMTactician_MctsTree/releases). Simply extract everything to your project, including the extension and the companion scripts. Once you do that, you may optionally change the configurations in `__MCTS_CONFIGS__` to suit your projects needs.

## Contributing to MCTS Tree Devkit

- Clone this repository.
- Open the project in GameMaker Studio and make your additions/changes to the `GMTactician_MctsTree` group. If applicable, also add the corresponding tests to the `GMTactician_MctsTree_test` group and run them from `gmta_mcts_test_all`.
- Open a pull request [here](https://github.com/dicksonlaw583/GMTactician_MctsTree/issues).
