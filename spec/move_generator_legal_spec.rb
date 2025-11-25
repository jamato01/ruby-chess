require_relative '../lib/chess'

describe Chess::MoveGenerator::Legal do
  describe '.generate' do
    it 'returns a non-empty array of legal moves for the start position' do
      board = Chess::Board.start_position
      moves = Chess::MoveGenerator::Legal.generate(board)
      expect(moves).to be_an(Array)
      expect(moves.length).to be > 0
    end
  end
end