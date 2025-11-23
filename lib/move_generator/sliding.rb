module Chess
  module MoveGenerator
    module Sliding
      def generate_rook_moves(board, color)
        # Checks which color currently in use and sets the blockers rook will stop at
        pieces = color == WHITE ? board.white_rooks : board.black_rooks
        enemy_pieces = color == BLACK ? board.white_pieces : board.black_pieces
        blockers = board.all_pieces

        moves = []

        Bitboard.each_bit(pieces) do |from|
          attacks = Attacks.rook_attacks(from, blockers)

          # Remove attacks on same-color pieces
          attacks &= ~board.pieces(color)

          # Handle capture flags
          Bitboard.each_bit(attacks) do |to|
            if enemy_pieces & (1 << to) != 0
              moves << Move.new(from, to, CAPTURE)
            else
              moves << Move.new(from, to)
            end
          end
        end

        # All possible rook moves:
        moves
      end

      def generate_bishop_moves(board, color)
        # Checks which color currently in use and sets the blockers bishop will stop at
        pieces = color == WHITE ? board.white_bishops : board.black_bishops
        enemy_pieces = color == BLACK ? board.white_pieces : board.black_pieces
        blockers = board.all_pieces

        moves = []

        Bitboard.each_bit(pieces) do |from|
          attacks = Attacks.bishop_attacks(from, blockers)

          # Remove attacks on same-color pieces
          attacks &= ~board.pieces(color)

          # Handle capture flags
          Bitboard.each_bit(attacks) do |to|
            if enemy_pieces & (1 << to) != 0
              moves << Move.new(from, to, CAPTURE)
            else
              moves << Move.new(from, to)
            end
          end
        end

        # All possible bishop moves:
        moves
      end

      def generate_queen_moves(board, color)
        # Checks which color currently in use and sets the blockers queens will stop at
        pieces = color == WHITE ? board.white_queens : board.black_queens
        enemy_pieces = color == BLACK ? board.white_pieces : board.black_pieces
        blockers = board.all_pieces

        moves = []

        Bitboard.each_bit(pieces) do |from|
          attacks = Attacks.queen_attacks(from, blockers)

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

        # All possible queen moves:
        moves
      end
    end
  end
end