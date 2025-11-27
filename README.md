# Ruby Chess
TOP's [Chess Project](https://www.theodinproject.com/lessons/ruby-ruby-final-project), meant to be a final project for the Ruby Course


## Project Structure
```bash
`/ruby-chess`
├── `/bin`
|   └── `chess_gui` - Runs the GUI for the chess game
├── `/lib`
|   ├── `/gui`
|   |   └── `ruby2d_renderer.rb` - Handles the entire runtime using the `ruby2d` gem
|   ├── `/move_generator`
|   |   ├── `base.rb` - Generates pseudo-legal moves and calls for legality checks
|   |   ├── `legal.rb` - Takes psuedo-legal moves and checks for legality (king in check)
|   |   ├── `attacks.rb` - Generates queen, bishop, and rook moves and houses square attack check methods
|   |   ├── `sliding.rb` - Generates pseudo-legal moves for queens, bishops, and rooks of specified color
|   |   ├── `pawns.rb` - Generates pseudo-legal pawn moves for specified color (including promotions and en-passant)
|   |   └── `leaping.rb` - Generates pseudo-legal moves for kings and knights, as well as castling checks and moves
|   ├── `/utils`
|   |   └── `lookup_tables.rb` - Houses attack tables for knights, kings, and pawns for faster move generation
|   ├── `board.rb` - Handles board generation (bitboards & metadata), adding/removing pieces, in-check checks and board cloning
|   ├── `bitboard.rb` - Houses bitboard helper functions for accessing bits using square numbers
|   ├── `chess.rb` - Entry point for project, all `requires` statements here
|   ├── `constants.rb` - Houses constance, piece types, and move flags
|   ├── `game.rb` - Handles gameplay, saving, game history, and game win/draw/stalemate checks
|   ├── `move_applier.rb` - Applies Move objects and returns new board using #apply method
|   └── `move.rb` - Houses metadata for every move in object
├── `/saves` - Houses save files
├── `/spec`
|   ├── `attacks_spec.rb` - Unit tests for attacks
|   ├── `bitboard_spec.rb` - Unit tests for bitboard helper functions
|   ├── `board_spec.rb` - Unit tests for board initialization and adding and removing pieces
|   ├── `castling_spec.rb` - Unit tests for castling
|   ├── `en_passant_spec.rb` - Unit tests for en-passant
|   ├── `fifty_move_spec.rb` - Unit tests for 50-move draw rule
|   ├── `game_spec.rb` - Unit tests for game playing and game-end checks
|   ├── `leaping_spec.rb` - Unit tests for leaping piece move generation
|   ├── `move_applier_spec.rb` - Unit tests for move application
|   ├── `move_applier_special_spec.rb` - Unit tests for special moves (promotions)
|   ├── `move_generator_legal_spec.rb` - Unit tests for move legality filtering
|   ├── `move_spec.rb` - Unit tests for the move class
|   ├── `pawns_spec.rb` - Unit tests for pawn moves
|   └── `sliding_spec.rb` - Unit tests for rook, queen, and bishop moves
├── `.rspec`
├── `Gemfile`
├── `Gemfile.lock`
| 
└── `README.md`
```
## Getting started (run locally)

These instructions assume you have a recent Ruby (3.x) installed. On macOS/Linux it's recommended to use rbenv or rvm to manage Ruby versions.

1. Clone the repository

```bash
git clone https://github.com/jamato01/ruby-chess.git
cd ruby-chess
```

2. Install dependencies

This project uses `ruby2d` for a minimal GUI. Install Bundler (if you don't have it) and then install gems:

```bash
gem install bundler
bundle install
```

3. Run the GUI

If you have a desktop environment (X11/Wayland on Linux, macOS), run:

```bash
ruby bin/chess_gui
```

## Save / Load

The GUI exposes Save and Load controls. Saves are written to the `saves/` directory using Ruby's `Marshal` format. When a saved game is later ended (resign or force-draw), the GUI will remove the save file automatically.

## Promotion picker

When a pawn reaches the last rank the GUI shows a centered promotion picker so the player can choose queen/rook/bishop/knight instead of auto-queening.

## Force resign / force draw

The GUI provides `Resign` and `Force Draw` buttons; these immediately end the game and update the status text. If the game had an associated save file, the GUI will delete it when the game ends.

## Troubleshooting

- "Failed to start GUI" or similar errors: ensure Ruby2D is installed (`bundle install`) and you have an X server available. On headless systems use `xvfb-run`.
- If the promotion picker doesn't appear, make sure the move is actually a promotion move.

## Tests

There are RSpec specs under `spec/`. If you want to run the tests locally add `rspec` to your Gemfile and run `bundle install` and then:

```bash
bundle exec rspec
```