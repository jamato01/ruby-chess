module Chess
  class MoveApplier
    def self.apply(board, move)
      # return a new Board with updated bitboards
      from = move.from
      to = move.to

      color = board.side_to_move
      piece = board.piece_at(from)

      # Remove piece from original square
      board.remove_piece(color, piece, from)

      # Captures
      if move.capture?
        captured_piece = board.piece_at(to)
        board.remove_piece(board.opp(color), captured_piece, to)
      end

      # Place piece in new square (promote if necessary)
      if move.promotion?
        board.add_piece(color, move.promo_piece, to)
      else
        board.add_piece(color, piece, to)
      end

      # Special moves
      case move.type
      when DOUBLE_PAWN
        board.en_passant_square = pawn_en_passant_target(color, from, to)
      when EN_PASSANT
        captured = en_passant_capture_square(color, to)
        board.remove_piece(board.opp(color), :pawn, captured)
      when CASTLE_KINGSIDE
        move_rook_for_ks_castling(board, color)
      when CASTLE_QUEENSIDE
        move_rook_for_qs_castling(board, color)
      end

      board.side_to_move = board.opp(color)
      board
    end

    def pawn_en_passant_target(color, from, to)
      color == WHITE ? to - 8 : to + 8
    end

    def en_passant_capture_square(color, to)
      color == WHITE ? to - 8 : to + 8
    end

    def move_rook_for_ks_castling(board, color)
      if color == WHITE
        board.remove_piece(WHITE, :rook, 7)
        board.add_piece(WHITE, :rook, 5)
      else
        board.remove_piece(BLACK, :rook, 63)
        board.add_piece(BLACK, :rook, 61)
      end
    end

    def move_rook_for_qs_castling(board, color)
      if color = WHITE
        board.remove_piece(WHITE, :rook, 0)
        board.add_piece(WHITE, :rook, 3)
      else
        board.remove_piece(BLACK, :rook, 56)
        board.add_piece(BLACK, :rook, 59)
      end
    end
  end
end