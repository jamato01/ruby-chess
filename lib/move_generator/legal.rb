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
            # Pre-check: castling cannot be done if king is in check or if any square
            # the king traverses is attacked. Check those first to avoid allowing
            # castling through check.
            opp = board.opp(color)
            if (move.flags & CASTLE_KINGSIDE) != 0
              # White crosses f1(5) -> g1(6), Black crosses f8(61) -> g8(62)
              cross_sq = color == WHITE ? 5 : 61
              dest_sq = move.to
              next if board.in_check?(color)
              next if MoveGenerator::Attacks.square_attacked?(board, cross_sq, opp)
              next if MoveGenerator::Attacks.square_attacked?(board, dest_sq, opp)
            end

            if (move.flags & CASTLE_QUEENSIDE) != 0
              # White crosses d1(3) -> c1(2), Black crosses d8(59) -> c8(58)
              cross_sq = color == WHITE ? 3 : 59
              dest_sq = move.to
              next if board.in_check?(color)
              next if MoveGenerator::Attacks.square_attacked?(board, cross_sq, opp)
              next if MoveGenerator::Attacks.square_attacked?(board, dest_sq, opp)
            end

            # Need to test the move on a cloned board
            temp_board = board.clone
            MoveApplier.apply(temp_board, move)

            # If king isn't in check after the move, the move is legal and we can keep it
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