module Chess
  module MoveGenerator
    module Leaping
      # Kight moves using lookup tables
      def generate_knight_moves(board, color)
        pieces = color == WHITE ? board.white_knights : board.black_knights
        
        moves = []

        Bitboard.each_bit(pieces) do |from|
          attacks = LookupTables::KNIGHT_ATTACKS[from]

          # Remove attacks on same-color pieces
          attacks &= ~board.pieces(color)

          Bitboard.each_bit(attacks) do |to|
            moves << Move.new(from, to)
          end
        end

        # All possible knight moves:
        moves
      end

      # King moves using lookup tables.. also.. castling??????
      def generate_king_moves(board, color)
        king = color == WHITE ? board.white_kings : board.black_kings

        moves = []

        attacks = LookupTables::KING_ATTACKS[king] & ~board.pieces(color)

        Bitboard.each_bit(attacks) do |to|
          moves << Move.new(king, to)
        end

        # Add castling later
        moves
      end
    end
  end
end