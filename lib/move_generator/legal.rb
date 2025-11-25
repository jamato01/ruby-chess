module Chess
  module MoveGenerator
    module Legal
      include Attacks, Pawns, Sliding, Leaping
      def self.generate(board)
        moves = []
        color = board.side_to_move
        # gather pseudo-legal moves
        moves = generate_pseudo_legal(board, color)
        
        
        # filter ones where king is in check after move
        legal_moves = []
        
        moves.each do |move|
          # Need to test the move on a cloned board
          temp_board = board.clone
          MoveApplier.apply(temp_board, move)

          # If king isn't in check, the move is legal and we can keep it
          legal_moves << move unless temp_board.in_check?(color)
        end
        legal_moves
      end

      def self.generate_pseudo_legal(board, color)
        moves = []
        moves.concat Pawns.generate_pawn_moves(board, color)
        moves.concat Sliding.generate_rook_moves(board, color)
        moves.concat Sliding.generate_bishop_moves(board, color)
        moves.concat Sliding.generate_queen_moves(board, color)
        moves.concat Leaping.generate_knight_moves(board, color)
        moves.concat Leaping.generate_king_moves(board, color)
        moves
      end
    end
  end
end