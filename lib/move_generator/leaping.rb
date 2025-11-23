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

        # Add castling later
        moves
      end
    end
  end
end