module Chess
  class Game
    attr_reader :board, :history

    def initialize(board = Board.start_position)
      @board = board
      @history = []
    end

    def make_move(move)
      @history << @board.clone
      @board = MoveApplier.apply(@board, move)
    end

    # Return true if the 50-move rule draw condition is met.
    # The halfmove_clock counts half-moves (ply) since the last pawn move or capture.
    # 50 full moves (for each side) == 100 half-moves.
    def fifty_move_draw?
      (@board.halfmove_clock || 0) >= 100
    end
  end
end