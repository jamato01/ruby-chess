require_relative '../lib/chess'

describe Chess::MoveGenerator::Attacks do
  def board_with_positions(white: {}, black: {})
    Chess::Board.new(
      white_pawns: white.fetch(:pawn, 0),
      white_knights: white.fetch(:knight, 0),
      white_bishops: white.fetch(:bishop, 0),
      white_rooks: white.fetch(:rook, 0),
      white_queens: white.fetch(:queen, 0),
      white_kings: white.fetch(:king, 0),
      black_pawns: black.fetch(:pawn, 0),
      black_knights: black.fetch(:knight, 0),
      black_bishops: black.fetch(:bishop, 0),
      black_rooks: black.fetch(:rook, 0),
      black_queens: black.fetch(:queen, 0),
      black_kings: black.fetch(:king, 0),
      side_to_move: Chess::WHITE,
      castling_rights: 0,
      en_passant: nil
    )
  end

  it 'detects a rook attacking a king on the same file with no blockers' do
    # black rook on e8 (60), white king on e1 (4)
    board = board_with_positions(white: { king: 1 << 4 }, black: { rook: 1 << 60 })
    expect(Chess::MoveGenerator::Attacks.square_attacked?(board, 4, Chess::BLACK)).to be true
  end

  it 'does not consider a blocked sliding attack as reaching the target' do
    # black rook on e8 (60), blocker on e5 (36), white king on e1 (4)
    board = board_with_positions(white: { king: 1 << 4 }, black: { rook: 1 << 60 })
    # add blocker on e5
    board.add_piece(Chess::WHITE, :pawn, 36)
    expect(Chess::MoveGenerator::Attacks.square_attacked?(board, 4, Chess::BLACK)).to be false
  end
end
