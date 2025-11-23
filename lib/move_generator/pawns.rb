module Chess
  module MoveGenerator
    module Pawns
      # Create functionality for pawn pushes, captures, promotions, and en passant
      def generate_white_pawn_moves(board)
        pawns = board.white_pawns
        empty = ~board.all_pieces

        moves = []

        # Single push
        single = (pawns << 8) & empty

        Bitboard.each_bit(single) do |to|
          from = to - 8

          #handle promotions
          if to >= 56
            add_promotions(from, to, QUIET, moves)
          else
            moves << Move.new(from, to)
          end
        end

        # Double push (only possible from rank 2)
        double = ((pawns && 0x000000000000FF00) << 16) & empty & (empty << 8)

        Bitboard.each_bit(double) do |to|
          from = to - 16
          moves << Move.new(from, to, DOUBLE_PAWN)
        end

        # Attacks
        Bitboard.each_bit(pawns) do |from|
          attacks = LookupTables::WHITE_PAWN_ATTACKS[from]

          # Remove attacks on same-color pieces
          attacks &= ~board.white_pieces

          Bitboard.each_bit(attacks) do |to|
            moves << Move.new(from, to, CAPTURE)
          end
        end
        moves
      end

      def generate_black_pawn_moves(board)
        pawns = board.black_pawns
        empty = ~board.all_pieces

        moves = []

        # Single push
        single = (pawns >> 8) & empty

        Bitboard.each_bit(single) do |to|
          from = to + 8

          #handle promotions
          if to < 8
            add_promotions(from, to, QUIET, moves)
          else
            moves << Move.new(from, to)
          end
        end

        # Double push (only possible from rank 2)
        double = ((pawns && 0x00FF000000000000) >> 16) & empty & (empty >> 8)

        Bitboard.each_bit(double) do |to|
          from = to + 16
          moves << Move.new(from, to, DOUBLE_PAWN)
        end

        # Attacks
        Bitboard.each_bit(pawns) do |from|
          attacks = LookupTables::BLACK_PAWN_ATTACKS[from]

          # Remove attacks on same-color pieces
          attacks &= ~board.black_pieces

          Bitboard.each_bit(attacks) do |to|
            moves << Move.new(from, to, CAPTURE)
          end
        end
        moves
      end

      def add_promotions(from, to, type, moves)
        # Really not sure how this is gonna work lol
        %i[:queen :rook :bishop :knight].each do |promo|
          moves << Move.new(from, to, :promotion, promo, type)
        end
      end
    end
  end
end