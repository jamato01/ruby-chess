require_relative '../lib/chess'

describe Chess::MoveGenerator::Pawns do
  def make_board_with_white_pawn(square)
    Chess::Board.new(
      white_pawns: 1 << square,
      white_knights: 0,
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

  it 'generates single and double pawn pushes from starting rank' do
    # e2 -> square 12
    board = make_board_with_white_pawn(12)
    moves = Chess::MoveGenerator::Pawns.generate_pawn_moves(board, Chess::WHITE)
    expect(moves.any? { |m| m.from == 12 && m.to == 20 }).to be true
    expect(moves.any? { |m| m.from == 12 && m.to == 28 && (m.flags & Chess::DOUBLE_PAWN) != 0 }).to be true
  end

  it 'generates promotion moves when moving into back rank' do
    # place white pawn on e7 (52)
    board = make_board_with_white_pawn(52)
    moves = Chess::MoveGenerator::Pawns.generate_pawn_moves(board, Chess::WHITE)
    # promotions should include moves to square 60 (e8)
    expect(moves.any? { |m| m.to == 60 && m.is_promotion? }).to be true
  end
end
