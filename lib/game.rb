module Chess
  class Game
    attr_reader :board, :history

    def initialize
      @board = Board.start_position
      @history = []
    end

    def make_move(move)
      @history << @board
      @board = MoveApplier.apply(@board, move)
    end
  end
end