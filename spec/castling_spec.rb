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

describe 'Castling rights clearing' do
  it 'clears both white castling rights when the white king moves' do
    board = Chess::Board.start_position
    # King e1 -> e2
    move = Chess::Move.new(from: 4, to: 12)
    result = Chess::MoveApplier.apply(board, move)

    # white castling bits are the low two bits (0b0011)
    expect((result.castling_rights & 0b0011)).to eq(0)
  end

  it 'clears the appropriate white castling right when a rook moves' do
    board = Chess::Board.start_position
    # Move white kingside rook h1 -> h2 (7 -> 15)
    move = Chess::Move.new(from: 7, to: 15)
    result = Chess::MoveApplier.apply(board, move)

    # white kingside bit (0b0001) should be cleared
    expect((result.castling_rights & 0b0001)).to eq(0)
    # white queenside bit may remain
    expect((result.castling_rights & 0b0010)).to_not eq(0)
  end

  it 'clears white castling right when white rook is captured on its original square' do
    # Place a white rook on h1 (7) and a black rook poised to capture it from h3 (23)
    board = Chess::Board.new(
      white_pawns: 0,
      white_knights: 0,
      white_bishops: 0,
      white_rooks: 1 << 7,
      white_queens: 0,
      white_kings: 1 << 4,
      black_pawns: 0,
      black_knights: 0,
      black_bishops: 0,
      black_rooks: 1 << 23,
      black_queens: 0,
      black_kings: 0,
      side_to_move: Chess::BLACK,
      castling_rights: 0b0001,
      en_passant: nil
    )

    # Black captures h1
    move = Chess::Move.new(from: 23, to: 7, flags: Chess::CAPTURE)
    result = Chess::MoveApplier.apply(board, move)

    expect((result.castling_rights & 0b0001)).to eq(0)
  end
end
