require_relative '../lib/chess'

describe Chess::MoveGenerator::Sliding do
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
    # expect a few directions reachable: d3 (19), d5 (35), c4 (26), e4 (28)
    expect(moves.any? { |m| m.from == 27 && m.to == 19 }).to be true
    expect(moves.any? { |m| m.from == 27 && m.to == 35 }).to be true
    expect(moves.any? { |m| m.from == 27 && m.to == 26 }).to be true
    expect(moves.any? { |m| m.from == 27 && m.to == 28 }).to be true
  end
end
