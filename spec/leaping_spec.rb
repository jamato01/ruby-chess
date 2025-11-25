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

  context 'King moves' do
    def make_board_with_king(square)
      Chess::Board.new(
        white_pawns: 0,
        white_knights: 0,
        white_bishops: 0,
        white_rooks: 0,
        white_queens: 0,
        white_kings: 1 << square,
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
      # d4 -> square 27; expected moves include c4 (26), d3 (19), e5 (36)
      board = make_board_with_king(27)
      moves = Chess::MoveGenerator::Leaping.generate_king_moves(board, Chess::WHITE)
      expect(moves.any? { |m| m.from == 27 && m.to == 26 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 19 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 36 }).to be true
    end

    it 'generates knight leaps from starting squares with blockers' do
      board = make_board_with_king(27)
      board.add_piece(Chess::BLACK, :pawn, 26)
      board.add_piece(Chess::WHITE, :pawn, 28)
      # King should be able to take Black pawn on c4 (26), but not White pawn on e4(28)
      # We are NOT checking legal moves here so the moves that put king in check should not be considered in these tests
      moves = Chess::MoveGenerator::Leaping.generate_king_moves(board, Chess::WHITE)
      expect(moves.any? { |m| m.from == 27 && m.to == 26 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 28 }).to be false
    end
  end
end
