module Chess
  class Game
    attr_reader :board, :history

    def initialize(board = Board.start_position)
      @board = board
      @history = []
      # position_counts maps Board#position_key => occurrences
      @position_counts = Hash.new(0)
      # record starting position
      @position_counts[@board.position_key] += 1
    end

    def make_move(move)
      @history << @board.clone
      @board = MoveApplier.apply(@board, move)
      # update repetition counts for new position
      @position_counts[@board.position_key] += 1
    end

    # Return true if the 50-move rule draw condition is met.
    # The halfmove_clock counts half-moves (ply) since the last pawn move or capture.
    # 50 full moves (for each side) == 100 half-moves.
    def fifty_move_draw?
      (@board.halfmove_clock || 0) >= 100
    end

    # Checkmate: side to move is in check and has no legal moves
    def checkmate?
      color = @board.side_to_move
      return false unless @board.in_check?(color)
      moves = MoveGenerator::Legal.generate(@board)
      moves.empty?
    end

    # Stalemate: side to move is not in check but has no legal moves
    def stalemate?
      color = @board.side_to_move
      return false if @board.in_check?(color)
      moves = MoveGenerator::Legal.generate(@board)
      moves.empty?
    end

    def threefold_repetition?
      @position_counts[@board.position_key] >= 3
    end

    # Expose current position repetition count for debug/UI
    def position_count
      @position_counts[@board.position_key]
    end

    # Game over if checkmate, stalemate, or fifty-move draw
    def over?
      checkmate? || stalemate? || fifty_move_draw? || threefold_repetition?
    end

    # Returns winner color (WHITE/BLACK) if checkmate, nil for stalemate or draw
    def winner
      return nil if stalemate? || fifty_move_draw? || threefold_repetition?
      return (@board.side_to_move == WHITE ? BLACK : WHITE) if checkmate?
      nil
    end
  end
end