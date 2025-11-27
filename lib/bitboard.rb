module Chess
  module Bitboard
    def self.pop_lsb(bb)
      lsb = bb & -bb
      square = Math.log2(lsb).to_i
      [bb ^ lsb, square]
    end

    def self.each_bit(bb)
      while bb != 0
        lsb = bb & -bb
        square = Math.log2(lsb).to_i
        yield square
        bb &= bb - 1
      end
    end
  end
end