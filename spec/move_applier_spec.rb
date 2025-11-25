require_relative '../lib/chess'

describe Chess::MoveApplier do
  describe '#apply' do
    it 'moves a pawn from e2 to e4 without capture' do
      board = Chess::Board.start_position

      # e2 -> square 12, e4 -> square 28
      move = Chess::Move.new(from: 12, to: 28)

      result = Chess::MoveApplier.apply(board, move)

      # original square should be empty for white pawns
      expect((result.white_pawns & (1 << 12))).to eq(0)
      # destination should now contain the pawn
      expect((result.white_pawns & (1 << 28))).not_to eq(0)
      # side to move should flip
      expect(result.side_to_move).to eq(Chess::BLACK)
    end
  end
end
