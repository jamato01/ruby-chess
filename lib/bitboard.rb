module Chess
  module Bitboard
    def self.bit(square)
      1 << square
    end

    def self.pop_lsb(bb)
      lsb = bb & -bb
      square = Math.log2(lsb).to_i
      [bb ^ lsb, square]
    end
  end
end