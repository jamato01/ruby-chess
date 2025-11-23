module Chess
  WHITE = 0
  BLACK = 1

  PIECE_TYPES = [:pawn, :knight, :bishop, :rook, :queen, :king]

  # Move flags
  QUIET = 0x0
  CAPTURE = 0x1
  DOUBLE_PAWN = 0x2
  EN_PASSANT = 0x4
  CASTLE_KINGSIDE = 0x8
  CASTLE_QUEENSIDE = 0x9
  PROMOTION = 0x10
end