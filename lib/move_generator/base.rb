module Chess
  module MoveGenerator
    def self.legal_moves(board)
      Legal.generate(board)
    end
  end
end