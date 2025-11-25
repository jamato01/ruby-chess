require_relative '../lib/chess'

describe '50-move rule' do
  it 'detects draw after 50 full moves (100 halfmoves) without pawn move or capture' do
    board = Chess::Board.start_position
    # set halfmove_clock to 99 halfmoves elapsed
    board.halfmove_clock = 99

    game = Chess::Game.new(board)

    # make a quiet non-pawn non-capture move (move knight from b1 -> c3)
    move = Chess::Move.new(from: 1, to: 18)
    game.make_move(move)

    expect(game.fifty_move_draw?).to be true
  end
end
