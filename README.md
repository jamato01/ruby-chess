# Ruby Chess
TOP's [Chess Project](https://www.theodinproject.com/lessons/ruby-ruby-final-project), meant to be a final project for the Ruby Course


## Project Structure
`/ruby-chess`
├── `/lib`
|   ├── `/move_generator`
|   |   ├── `base.rb`
|   |   ├── `legal.rb`
|   |   ├── `attacks.rb`
|   |   ├── `sliding.rb`
|   |   ├── `pawns.rb`
|   |   └── `leaping.rb`
|   ├── `/utils`
|   |   └── `lookup_tables.rb`
|   ├── `board.rb`
|   ├── `bitboard.rb`
|   ├── `chess.rb`
|   ├── `constants.rb`
|   ├── `game.rb`
|   ├── `move_applier.rb`
|   ├── `move.rb`
|   └── `square.rb`
|
└── `README.md`

## File Descriptions
`lib/move_generator/base.rb`
Base file for all move generation, calls to generate all legal moves on board

`lib/move_generator/legal.rb`
Gathers pseudo-legal moves and removes those that put the king in check

`lib/move_generator/attacks.rb`
Houses plain-attack generation for pieces

`lib/move_generator/sliding.rb`
Generates pseudo-legal moves for sliding pieces (Rook, Bishop, & Queen)

`lib/move_generator/pawns.rb`
Generates pseudo-legal moves for pawns

`lib/move_generator/leaping.rb`
Generates pseudo-legal moves for leaping pieces (Knights, Kings)

`lib/utils/lookup_tables`
Houses lookup tables for all possible attacks on each square for kings, knights, and pawns

`lib/board.rb`
Generates full boards based on initialization or starting position

`lib/bitboard.rb`
Houses helper functions to manipulate or iterate through bitboards

`lib/chess.rb`
Serves as entry point for entire project, using all 'require_relative' statements

`lib/constants.rb`
Houses constant values, piece types, and move flags

`lib/game.rb`
Keeps track of board history and handles move making calls

`lib/move_applier.rb`
Applies Chess::Move objects to board

`lib/move.rb`
Move class to carry data for each move

`lib/square.rb`
Helper functions to describe and convert squares by strings with file/rank data or coordinates on a bitboard