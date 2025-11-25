require_relative '../lib/chess'

describe Chess::MoveApplier do
  it 'applies a promotion to a queen when pawn moves to back rank' do
    board = Chess::Board.new(
      white_pawns: 1 << 52, # e7
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

    move = Chess::Move.new(from: 52, to: 60, flags: Chess::PROMOTION, promotion: :queen)
    result = Chess::MoveApplier.apply(board, move)
    expect((result.white_queens & (1 << 60)) != 0).to be true
  end
end
