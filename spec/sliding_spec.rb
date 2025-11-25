require_relative '../lib/chess'

describe Chess::MoveGenerator::Sliding do
  context 'Rook moves' do
    def make_board_with_rook(square)
      Chess::Board.new(
        white_pawns: 0,
        white_knights: 0,
        white_bishops: 0,
        white_rooks: 1 << square,
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

    it 'generates orthogonal rook moves on empty board' do
      # d4 -> file 3, rank 3 -> square 27
      board = make_board_with_rook(27)
      moves = Chess::MoveGenerator::Sliding.generate_rook_moves(board, Chess::WHITE)
      # expect a few directions reachable: d3 (19), d8 (59), c4 (26), e4 (28)
      expect(moves.any? { |m| m.from == 27 && m.to == 19 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 59 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 26 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 28 }).to be true
    end

    it 'generates orthogonal rook moves with blockers' do
      board = make_board_with_rook(27)
      # Black Bishop on d6 (43) and White Bishop on b4 (25)
      board.add_piece(Chess::BLACK, :bishop, 43)
      board.add_piece(Chess::WHITE, :bishop, 25)
      moves = Chess::MoveGenerator::Sliding.generate_rook_moves(board, Chess::WHITE)
      # expect d5 (35), d6 (43) reachable, but d7 (51) not reachable
      expect(moves.any? { |m| m.from == 27 && m.to == 35 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 43 }).to be true
      expect(moves.any? { |m| m.from == 27 && m.to == 51 }).to be false
      expect(moves.any? { |m| m.from == 27 && m.to == 25 }).to be false
    end
  end

  def make_board_with_bishop(square)
    Chess::Board.new(
      white_pawns: 0,
      white_knights: 0,
      white_bishops: 1 << square,
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

  it 'generates diagonal rook moves on empty board' do
    board = make_board_with_bishop(27)
    moves = Chess::MoveGenerator::Sliding.generate_bishop_moves(board, Chess::WHITE)
    # expect a few directions reachable: a7 (48), b2 (9), g7 (54), g1 (6)
    expect(moves.any? { |m| m.from == 27 && m.to == 48 }).to be true
    expect(moves.any? { |m| m.from == 27 && m.to == 9 }).to be true
    expect(moves.any? { |m| m.from == 27 && m.to == 54 }).to be true
    expect(moves.any? { |m| m.from == 27 && m.to == 6 }).to be true
  end
end
