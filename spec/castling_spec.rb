require_relative '../lib/chess'

describe 'Castling move application' do
  it 'moves rook correctly on white kingside castling' do
    board = Chess::Board.new(
      white_pawns: 0,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 1 << 7, # h1
      white_queens: 0,
      white_kings: 1 << 4, # e1
      black_pawns: 0,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 0,
      black_queens: 0,
      black_kings: 0,
      side_to_move: Chess::WHITE,
      # allow white kingside (bit 0)
      castling_rights: 0b0001,
      en_passant: nil
    )

    move = Chess::Move.new(from: 4, to: 6, flags: Chess::CASTLE_KINGSIDE)
    result = Chess::MoveApplier.apply(board, move)

    # King should be on g1 (6)
    expect((result.white_kings & (1 << 6)) != 0).to be true
    # Rook should have moved from h1 (7) to f1 (5)
    expect((result.white_rooks & (1 << 7))).to eq(0)
    expect((result.white_rooks & (1 << 5)) != 0).to be true
  end

  it 'moves rook correctly on white queenside castling' do
    board = Chess::Board.new(
      white_pawns: 0,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 1 << 0, # a1
      white_queens: 0,
      white_kings: 1 << 4, # e1
      black_pawns: 0,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 0,
      black_queens: 0,
      black_kings: 0,
      side_to_move: Chess::WHITE,
      # allow white queenside (bit 1)
      castling_rights: 0b0010,
      en_passant: nil
    )

    move = Chess::Move.new(from: 4, to: 2, flags: Chess::CASTLE_QUEENSIDE)
    result = Chess::MoveApplier.apply(board, move)

    # King should be on c1 (2)
    expect((result.white_kings & (1 << 2)) != 0).to be true
    # Rook should have moved from a1 (0) to d1 (3)
    expect((result.white_rooks & (1 << 0))).to eq(0)
    expect((result.white_rooks & (1 << 3)) != 0).to be true
  end

  it 'moves rook correctly on black kingside castling' do
    board = Chess::Board.new(
      white_pawns: 0,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 0,
      white_queens: 0,
      white_kings: 0,
      black_pawns: 0,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 1 << 63, # h8
      black_queens: 0,
      black_kings: 1 << 60, # e8
      side_to_move: Chess::BLACK,
      # allow black kingside (bit 2 -> 0b0100)
      castling_rights: 0b0100,
      en_passant: nil
    )

    move = Chess::Move.new(from: 60, to: 62, flags: Chess::CASTLE_KINGSIDE)
    result = Chess::MoveApplier.apply(board, move)

    # King should be on g8 (62)
    expect((result.black_kings & (1 << 62)) != 0).to be true
    # Rook should have moved from h8 (63) to f8 (61)
    expect((result.black_rooks & (1 << 63))).to eq(0)
    expect((result.black_rooks & (1 << 61)) != 0).to be true
  end

  it 'moves rook correctly on black queenside castling' do
    board = Chess::Board.new(
      white_pawns: 0,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 0,
      white_queens: 0,
      white_kings: 0,
      black_pawns: 0,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 1 << 56, # a8
      black_queens: 0,
      black_kings: 1 << 60, # e8
      side_to_move: Chess::BLACK,
      # allow black queenside (bit 3 -> 0b1000)
      castling_rights: 0b1000,
      en_passant: nil
    )

    move = Chess::Move.new(from: 60, to: 58, flags: Chess::CASTLE_QUEENSIDE)
    result = Chess::MoveApplier.apply(board, move)

    # King should be on c8 (58)
    expect((result.black_kings & (1 << 58)) != 0).to be true
    # Rook should have moved from a8 (56) to d8 (59)
    expect((result.black_rooks & (1 << 56))).to eq(0)
    expect((result.black_rooks & (1 << 59)) != 0).to be true
  end
end
