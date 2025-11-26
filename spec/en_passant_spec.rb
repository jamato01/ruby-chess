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

describe 'En Passant move generation' do
  it 'generates an en-passant capture after an opponent double-pawn push' do
    # White pawn on e5 (36), black pawn on d7 (51)
    board = Chess::Board.new(
      white_pawns: 1 << 36,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 0,
      white_queens: 0,
      white_kings: 0,
      black_pawns: 1 << 51,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 0,
      black_queens: 0,
      black_kings: 0,
      side_to_move: Chess::BLACK,
      castling_rights: 0,
      en_passant: nil
    )

    # Black double pawn push d7 -> d5 (51 -> 35)
    double_move = Chess::Move.new(from: 51, to: 35, flags: Chess::DOUBLE_PAWN)
    after = Chess::MoveApplier.apply(board, double_move)

    # Now white pawn moves should include en-passant capture from e5 (36) to d6 (43)
    moves = Chess::MoveGenerator::Pawns.generate_pawn_moves(after, Chess::WHITE)
    expect(moves.any? { |m| m.from == 36 && m.to == 43 && (m.flags & Chess::EN_PASSANT) != 0 }).to be true
  end
end

describe 'Legal en-passant generation and edge cases' do
  it 'includes en-passant in legal moves when it does not expose the king to check' do
    # White pawn on e5 (36), black pawn on d7 (51) double-push to d5 (35)
    board = Chess::Board.new(
      white_pawns: 1 << 36,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 0,
      white_queens: 0,
      white_kings: 1 << 4,
      black_pawns: 1 << 51,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 0,
      black_queens: 0,
      black_kings: 0,
      side_to_move: Chess::BLACK,
      castling_rights: 0,
      en_passant: nil
    )

    # Black double pawn push d7 -> d5 (51 -> 35)
    double_move = Chess::Move.new(from: 51, to: 35, flags: Chess::DOUBLE_PAWN)
    after = Chess::MoveApplier.apply(board, double_move)

    # Now white legal moves should include en-passant capture from e5 (36) to d6 (43)
    legal_moves = Chess::MoveGenerator::Legal.generate(after)
    expect(legal_moves.any? { |m| m.from == 36 && m.to == 43 && (m.flags & Chess::EN_PASSANT) != 0 }).to be true
  end

  it 'does not include an en-passant move that would leave the king in check' do
    # En-passant that is pseudo-legal but should check the king (pinned pawn)
    board = Chess::Board.new(
      white_pawns: (1 << 0),
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 0,
      white_queens: 0,
      white_kings: 1 << 2,
      black_pawns: 1 << 17,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 1 << 3,
      black_queens: 0,
      black_kings: 0,
      side_to_move: Chess::BLACK,
      castling_rights: 0,
      en_passant: nil
    )

    # Black double push 17 -> 1
    double_move = Chess::Move.new(from: 17, to: 1, flags: Chess::DOUBLE_PAWN)
    after = Chess::MoveApplier.apply(board, double_move)

    legal_moves = Chess::MoveGenerator::Legal.generate(after)
    ep_move_present = legal_moves.any? { |m| m.from == 0 && m.to == 9 && (m.flags & Chess::EN_PASSANT) != 0 }

    expect(ep_move_present).to be false
  end
end
