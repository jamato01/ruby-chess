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
    end
  end
end