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
              moves << Move.new(from: from, to: to, flags: CAPTURE)
            else
              moves << Move.new(from: from, to: to)
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

        # For each king (should be only one), generate attacks from its square
        Bitboard.each_bit(king) do |from|
          attacks = LookupTables::KING_ATTACKS[from] & ~board.pieces(color)

          Bitboard.each_bit(attacks) do |to|
            if enemy_pieces & (1 << to) != 0
              moves << Move.new(from: from, to: to, flags: CAPTURE)
            else
              moves << Move.new(from: from, to: to)
            end
          end
        end

        # Add castling (ensure path squares are empty and rook exists)
        # White king on e1 (4)
        if (king & (1 << 4)) != 0
          # White Kingside: squares f1(5) and g1(6) must be empty and rook at h1(7)
          if (board.castling_rights & 0b0001) != 0
            if (( (1 << 5) | (1 << 6) ) & board.all_pieces) == 0 && (board.white_rooks & (1 << 7)) != 0
              moves << Move.new(from: 4, to: 6, flags: CASTLE_KINGSIDE)
            end
          end

          # White Queenside: squares b1(1), c1(2), d1(3) must be empty and rook at a1(0)
          if (board.castling_rights & 0b0010) != 0
            if (( (1 << 1) | (1 << 2) | (1 << 3) ) & board.all_pieces) == 0 && (board.white_rooks & (1 << 0)) != 0
              moves << Move.new(from: 4, to: 2, flags: CASTLE_QUEENSIDE)
            end
          end
        end

        # Black king on e8 (60)
        if (king & (1 << 60)) != 0
          # Black Kingside: squares f8(61) and g8(62) must be empty and rook at h8(63)
          if (board.castling_rights & 0b0100) != 0
            if (( (1 << 61) | (1 << 62) ) & board.all_pieces) == 0 && (board.black_rooks & (1 << 63)) != 0
              moves << Move.new(from: 60, to: 62, flags: CASTLE_KINGSIDE)
            end
          end

          # Black Queenside: squares b8(57), c8(58), d8(59) must be empty and rook at a8(56)
          if (board.castling_rights & 0b1000) != 0
            if (( (1 << 57) | (1 << 58) | (1 << 59) ) & board.all_pieces) == 0 && (board.black_rooks & (1 << 56)) != 0
              moves << Move.new(from: 60, to: 58, flags: CASTLE_QUEENSIDE)
            end
          end
        end
        moves
      end
      
      module_function :generate_knight_moves, :generate_king_moves
    end
  end
end