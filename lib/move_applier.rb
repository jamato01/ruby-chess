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
      if move.is_promotion?
        board.add_piece(color, move.promotion, to)
      else
        board.add_piece(color, piece, to)
      end

      # Special moves
      case move.flags
      when DOUBLE_PAWN
        # set en_passant target square on board
        board.en_passant = pawn_en_passant_target(color, from, to)
      when EN_PASSANT
        captured = en_passant_capture_square(color, to)
        board.remove_piece(board.opp(color), :pawn, captured)
      when CASTLE_KINGSIDE
        move_rook_for_ks_castling(board, color)
      when CASTLE_QUEENSIDE
        move_rook_for_qs_castling(board, color)
      end

      # Halfmove clock (for 50-move rule): reset on pawn move or capture, otherwise increment
      if move.capture? || piece == :pawn || move.is_promotion?
        board.halfmove_clock = 0
      else
        board.halfmove_clock = (board.halfmove_clock || 0) + 1
      end

      # Only the immediate opponent move can capture en-passant; clear the en_passant
      # square after the next move if not a double pawn push.
      board.en_passant = nil if move.flags != DOUBLE_PAWN

      board.side_to_move = board.opp(color)
      board
    end

    def self.pawn_en_passant_target(color, from, to)
      color == WHITE ? to - 8 : to + 8
    end

    def self.en_passant_capture_square(color, to)
      color == WHITE ? to - 8 : to + 8
    end

    def self.move_rook_for_ks_castling(board, color)
      if color == WHITE
        board.remove_piece(WHITE, :rook, 7)
        board.add_piece(WHITE, :rook, 5)
      else
        board.remove_piece(BLACK, :rook, 63)
        board.add_piece(BLACK, :rook, 61)
      end
    end

    def self.move_rook_for_qs_castling(board, color)
      if color == WHITE
        board.remove_piece(WHITE, :rook, 0)
        board.add_piece(WHITE, :rook, 3)
      else
        board.remove_piece(BLACK, :rook, 56)
        board.add_piece(BLACK, :rook, 59)
      end
    end
  end
end