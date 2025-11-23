module Chess
  module LookupTables
    KNIGHT_ATTACKS = Array.new(64) do |square|
      attacks = 0
      rank = square / 8
      file = square % 8

      moves = [
        [2, 1], [1, 2], [-1, 2], [-2, 1,], [-2, -1],
        [-2, -1], [-1, -2], [1, -2], [2, -1]
      ]

      moves.each do |dr, df|
        r = rank + dr
        f = file + df
        next if r < 0 || r > 7 || f < 0 || f > 7
        attacks |= 1 << (r * 8 + f)
      end
      attacks
    end

    KING_ATTACKS = Array.new(64) do |square|
      attacks = 0
      rank = square / 8
      file = square % 8

      moves = [
        [1, 0], [1, 1], [0, 1], [-1, 1],
        [-1, 0], [-1, -1], [0, -1], [1, -1]
      ]

      moves.each do |dr, df|
        r = rank + dr
        f = file + df
        next if r < 0 || r > 7 || f < 0 || f > 7
        attacks |= 1 << (r * 8 + f)
      end
      attacks
    end

    WHITE_PAWN_ATTACKS = Array.new(64) do |square|
      attacks = 0
      rank = square / 8
      file = square % 8

      moves = [
        [1, 1], [1, -1]
      ]
      moves.each do |dr, df|
        r = rank + dr
        f = file + df
        next if r < 0 || r > 7 || f < 0 || f > 7
        attacks |= 1 << (r * 8 + f)
      end
      attacks
    end

    BLACK_PAWN_ATTACKS = Array.new(64) do |square|
      attacks = 0
      rank = square / 8
      file = square % 8

      moves = [
        [-1, 1], [-1, -1]
      ]
      moves.each do |dr, df|
        r = rank + dr
        f = file + df
        next if r < 0 || r > 7 || f < 0 || f > 7
        attacks |= 1 << (r * 8 + f)
      end
      attacks
    end
  end
end