require_relative '../lib/chess'

describe Chess::MoveGenerator::Leaping do
  context 'Knight moves' do
    def make_board_with_knight(square)
      Chess::Board.new(
        white_pawns: 0,
        white_knights: 1 << square,
        white_bishops: 0,
        white_rooks: 0,
        white_queens: 0,
        white_kings: 0,
        black_pawns: 0,
        black_knights: 0,
        black_bishops: 0,
        black_rooks: 0,
        black_queens: 0,
        black_kings: 0,
        side_to_move: Chess::WHITE,
        castling_rights: 0,
        en_passant: nil
      )
    end

    it 'generates knight leaps from starting squares on empty board' do
      # b1 -> square 1; expected leaps include d2 (11) and c3 (18)
      board = make_board_with_knight(1)
      moves = Chess::MoveGenerator::Leaping.generate_knight_moves(board, Chess::WHITE)
      expect(moves.any? { |m| m.from == 1 && m.to == 11 }).to be true
      expect(moves.any? { |m| m.from == 1 && m.to == 18 }).to be true
    end

    it 'generates knight leaps from starting squares with blockers' do
      board = make_board_with_knight(1)
      board.add_piece(Chess::BLACK, :rook, 16)
      board.add_piece(Chess::WHITE, :rook, 18)
      # Black rook should be able to be taken on a3 (16), White rook should not be able to be taken on c3 (18)
      moves = Chess::MoveGenerator::Leaping.generate_knight_moves(board, Chess::WHITE)
      expect(moves.any? { |m| m.from == 1 && m.to == 11 }).to be true
      expect(moves.any? { |m| m.from == 1 && m.to == 16 }).to be true
      expect(moves.any? { |m| m.from == 1 && m.to == 18 }).to be false
    end
  end
end
