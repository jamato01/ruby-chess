require_relative '../lib/chess'

describe 'En Passant capture via MoveApplier' do
  it 'sets en_passant target after a double pawn push and captures correctly' do
    # Initial board: white pawn on e2 (12), black pawn on d4 (27)
    board = Chess::Board.new(
      white_pawns: 1 << 12,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 0,
      white_queens: 0,
      white_kings: 0,
      black_pawns: 1 << 27,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 0,
      black_queens: 0,
      black_kings: 0,
      side_to_move: Chess::WHITE,
      castling_rights: 0,
      en_passant: nil
    )

    # White double pawn push e2 -> e4 (12 -> 28)
    double_move = Chess::Move.new(from: 12, to: 28, flags: Chess::DOUBLE_PAWN)
    result = Chess::MoveApplier.apply(board, double_move)

    # en_passant target should be e3 (20)
    expect(result.en_passant).to eq(20)

    # Now black to move: perform en-passant capture from d4 (27) to e3 (20)
    ep_move = Chess::Move.new(from: 27, to: 20, flags: Chess::EN_PASSANT)
    result2 = Chess::MoveApplier.apply(result, ep_move)

    # Black pawn should now be on e3 (20)
    expect((result2.black_pawns & (1 << 20)) != 0).to be true

    # The white pawn that was on e4 (28) should have been removed
    expect((result2.white_pawns & (1 << 28))).to eq(0)
  end
end
