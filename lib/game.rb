module Chess
  class Game
  attr_reader :board, :history
  attr_reader :forced_result
  attr_accessor :saved_path

    def initialize(board = Board.start_position)
      @board = board
      @history = []
      # position_counts maps Board#position_key => occurrences
      @position_counts = Hash.new(0)
      # record starting position
      @position_counts[@board.position_key] += 1
      # forced_result: nil or { type: :resign|:draw, winner: color_or_nil }
      @forced_result = nil
    end

    def make_move(move)
      @history << @board.clone
      @board = MoveApplier.apply(@board, move)
      # update repetition counts for new position
      @position_counts[@board.position_key] += 1
    end

    # Save / load helpers
    def save(path)
      dir = File.dirname(path)
      Dir.mkdir(dir) unless Dir.exist?(dir)
      File.binwrite(path, Marshal.dump(self))
      # remember the saved path on this game instance so UI can clean it up later
      @saved_path = path
      path
    end

    def self.load(path)
      g = Marshal.load(File.binread(path))
      # make loaded game aware of the file it was loaded from
      if g.respond_to?(:saved_path=)
        g.saved_path = path
      else
        g.instance_variable_set(:@saved_path, path)
      end
      g
    end

    # Forceful actions
    def resign(color)
      @forced_result = { type: :resign, winner: opp_color(color) }
    end

    def force_draw
      @forced_result = { type: :draw, winner: nil }
    end

    def opp_color(color)
      color == WHITE ? BLACK : WHITE
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

    # Game over if checkmate, stalemate, fifty-move draw, threefold repetition or forced results
    def over?
      return true if @forced_result
      checkmate? || stalemate? || fifty_move_draw? || threefold_repetition?
    end

    # Returns winner color (WHITE/BLACK) if checkmate or forced resignation,
    # nil for stalemate or draw or forced draw
    def winner
      if @forced_result
        return @forced_result[:winner]
      end

      return nil if stalemate? || fifty_move_draw? || threefold_repetition?
      return (@board.side_to_move == WHITE ? BLACK : WHITE) if checkmate?
      nil
    end
  end
end