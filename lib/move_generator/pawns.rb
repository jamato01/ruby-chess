module Chess
  module MoveGenerator
    module Pawns
      # Create functionality for pawn pushes, captures, promotions, and en passant
      def generate_pawn_moves(board, color)
        color == WHITE ? generate_white_pawn_moves(board) : generate_black_pawn_moves(board)
      end

      def generate_white_pawn_moves(board)
        pawns = board.white_pawns
        empty = ~board.all_pieces

        moves = []

        # Single push
        single = (pawns << 8) & empty

        Bitboard.each_bit(single) do |to|
          from = to - 8

          # Handle Promotions
          # For white pawns, promotions occur when moving to rank 8
          if to >= 56
            add_promotions(from, to, QUIET, moves)
          else
            moves << Move.new(from: from, to: to)
          end
        end

        # Double push (only possible from rank 2)
        double = ((pawns & 0x000000000000FF00) << 16) & empty & (empty << 8)

        Bitboard.each_bit(double) do |to|
          from = to - 16
          moves << Move.new(from: from, to: to, flags: DOUBLE_PAWN)
        end

        # Attacks
        Bitboard.each_bit(pawns) do |from|
          attacks = LookupTables::WHITE_PAWN_ATTACKS[from]

          # Remove attacks on same-color pieces
          attacks &= ~board.white_pieces

          # Capture attacks (squares occupied by enemy pieces)
          capture_attacks = attacks & board.black_pieces

          # Handle promotions on captures
          Bitboard.each_bit(capture_attacks) do |to|
            # For white pawns, promotions occur when moving to rank 8
            if to >= 56
              add_promotions(from, to, CAPTURE, moves)
            else
              moves << Move.new(from: from, to: to, flags: CAPTURE)
            end
          end

          # En-passant capture: if en_passant square exists and this pawn can attack it,
          # add an en-passant capture move (captures the pawn that double-pushed)
          if board.en_passant && (attacks & (1 << board.en_passant)) != 0
            moves << Move.new(from: from, to: board.en_passant, flags: EN_PASSANT | CAPTURE)
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

          # Handle promotions
          # For black pawns, promotions occur when moving to rank 1
          if to < 8
            add_promotions(from, to, QUIET, moves)
          else
            moves << Move.new(from: from, to: to)
          end
        end

        # Double push (only possible from rank 2)
        double = ((pawns & 0x00FF000000000000) >> 16) & empty & (empty >> 8)

        Bitboard.each_bit(double) do |to|
          from = to + 16
          moves << Move.new(from: from, to: to, flags: DOUBLE_PAWN)
        end

        # Attacks
        Bitboard.each_bit(pawns) do |from|
          attacks = LookupTables::BLACK_PAWN_ATTACKS[from]

          # Remove attacks on same-color pieces
          attacks &= ~board.black_pieces

          # Capture attacks (squares occupied by enemy pieces)
          capture_attacks = attacks & board.white_pieces

          # Handle promotions on captures
          Bitboard.each_bit(capture_attacks) do |to|
            # For black pawns, promotions occur when moving to rank 1
            if to < 8
              add_promotions(from, to, CAPTURE, moves)
            else
              moves << Move.new(from: from, to: to, flags: CAPTURE)
            end
          end

          # En-passant capture for black pawns
          if board.en_passant && (attacks & (1 << board.en_passant)) != 0
            moves << Move.new(from: from, to: board.en_passant, flags: EN_PASSANT | CAPTURE)
          end
        end
        moves
      end

      def add_promotions(from, to, flags, moves)
        # Add PROMOTION flag
        flags |= PROMOTION
        # Add moves for every type of promotion
        [:queen, :rook, :bishop, :knight].each do |promo|
          moves << Move.new(from: from, to: to, flags: flags, promotion: promo)
        end
      end

      # Make module functions so that they can be called as class functions
      module_function :generate_pawn_moves, :generate_white_pawn_moves, :generate_black_pawn_moves, :add_promotions
    end
  end
end