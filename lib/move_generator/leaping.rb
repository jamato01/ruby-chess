module Chess
  module MoveGenerator
    module Leaping
      # Kight moves using lookup tables
      def generate_knight_moves(board, color)
        pieces = color == WHITE ? board.white_knights : board.black_knights
        enemy_pieces = color == BLACK ? board.white_pieces : board.black_pieces
        
        moves = []

        Bitboard.each_bit(pieces) do |from|
          attacks = LookupTables::KNIGHT_ATTACKS[from]

          # Remove attacks on same-color pieces
          attacks &= ~board.pieces(color)

          Bitboard.each_bit(attacks) do |to|
            if enemy_pieces & (1 << to) != 0
              moves << Move.new(from, to, CAPTURE)
            else
              moves << Move.new(from, to)
            end
          end
        end

        # All possible knight moves:
        moves
      end

      # King moves using lookup tables.. also.. castling??????
      def generate_king_moves(board, color)
        king = color == WHITE ? board.white_kings : board.black_kings
        enemy_pieces = color == BLACK ? board.white_pieces : board.black_pieces

        moves = []

        attacks = LookupTables::KING_ATTACKS[king] & ~board.pieces(color)

        Bitboard.each_bit(attacks) do |to|
          if enemy_pieces & (1 << to) != 0
            moves << Move.new(from, to, CAPTURE)
          else
            moves << Move.new(from, to)
          end
        end

        # Add castling
        if (king & (1 << 4)) != 0
          if (board.castling_rights & 0b0001) != 0
            # White Kingside Castle
            moves << Move.new(4, 6, CASTLE_KINGSIDE)
          end
          if (board.castling_rights & 0b0010) != 0
            # White Queenside Castle
            moves << Move.new(4, 2, CASTLE_QUEENSIDE)
          end
        end
        if (king & (1 << 60)) != 0
          if (board.castling_rights & 0b0100) != 0
            # Black Kingside Castle
            moves << Move.new(60, 62, CASTLE_KINGSIDE)
          end
          if (board.castling_rights & 0b1000) != 0
            # Black Queenside Castle
            moves << Move.new(60, 58, CASTLE_KINGSIDE)
          end
        end
        moves
      end
    end
  end
end