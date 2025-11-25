module Chess
  module MoveGenerator
    module Attacks
      # Generates attack masks for check detection, pins, etc
      def rook_attacks(square, blockers)
        attacks = 0
        directions = [8, -8, 1, -1] # Up, down, left, right on bitboard

        directions.each do |dir|
          s = square
          loop do
            s += dir
            break if s < 0 || s > 63

            # Handle wrapping around ranks a/h 
            if dir == 1 && s % 8 == 0 then break end
            if dir == -1 && s % 8 == 7 then break end

            attacks |= 1 << s

            # End if piece hits blocker
            break if blockers & (1 << s) != 0
          end
        end
        attacks
      end

      def bishop_attacks(square, blockers)
        attacks = 0
        directions = [7, -7, 9, -9] # NW, SW, NE, SE on bitboard

        directions.each do |dir|
          s = square
          loop do
            s += dir
            break if s < 0 || s > 63

            # Handle wrapping around ranks a/h
            df = (s % 8) - ((s - dir) % 8)
            break if df.abs != 1

            attacks |= 1 << s
            
            # End if piece hits blocker
            break if blockers & (1 << s) != 0
          end
        end
        attacks
      end

      def queen_attacks(square, blockers)
        # Just combine the bitboards of the attacks for rooks and bishops on the same square
        rook_attacks(square, blockers) | bishop_attacks(square, blockers)
      end

      # Expose these as module functions so callers can invoke Attacks.rook_attacks(...)
      module_function :rook_attacks, :bishop_attacks, :queen_attacks

      def self.square_attacked?(board, square, by_color)
        return true if pawn_attacks_square?(board, square, by_color)
        return true if knight_attacks_square?(board, square, by_color)
        return true if king_attacks_square?(board, square, by_color)
        return true if sliding_attacks_square?(board, square, by_color)
        false
      end

      def self.pawn_attacks_square?(board, square, by_color)
        pawn_attacks = by_color == WHITE ? LookupTables::WHITE_PAWN_ATTACKS[square] : LookupTables::BLACK_PAWN_ATTACKS[square]
        pawn_bb = by_color == WHITE ? board.white_pawns : board.black_pawns
        (pawn_attacks & pawn_bb) != 0
      end


      def self.knight_attacks_square?(board, square, by_color)
        knight_bb = by_color == WHITE ? board.white_knights : board.black_knights
        (LookupTables::KNIGHT_ATTACKS[square] & knight_bb) != 0
      end

      def self.king_attacks_square?(board, square, by_color)
        king_bb = by_color == WHITE ? board.white_kings : board.black_kings
        (LookupTables::KING_ATTACKS[square] & king_bb) != 0
      end

      def self.sliding_attacks_square?(board, square, by_color)
        blockers = board.all_pieces
        target_mask = 1 << square
        # Bishop and Queen check
  bishop_like = (by_color == WHITE ? 
          (board.white_bishops | board.white_queens) : 
          (board.black_bishops | board.black_queens))

        # Rook and Queen check
  rook_like   = (by_color == WHITE ?
          (board.white_rooks | board.white_queens) :
          (board.black_rooks | board.black_queens))

        Bitboard.each_bit(bishop_like) do |from|
          attacks = bishop_attacks(from, blockers)
          return true if (attacks & target_mask) != 0
        end

        Bitboard.each_bit(rook_like) do |from|
          attacks = rook_attacks(from, blockers)
          return true if (attacks & target_mask) != 0
        end
        false
      end
    end
  end
end