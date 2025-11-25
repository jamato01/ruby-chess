require_relative '../lib/chess'

describe Chess::Board do
  describe '#start_position' do
    let(:board) { Chess::Board.start_position }

    it 'places white pawns on the second rank' do
      expect(board.white_pawns).to eq(0x000000000000FF00)
    end

    it 'places black pawns on the seventh rank' do
      expect(board.black_pawns).to eq(0x00FF000000000000)
    end

    it 'has white rooks on a1 and h1' do
      # a1 -> square 0, h1 -> square 7
      expect((board.white_rooks & (1 << 0)) != 0).to be true
      expect((board.white_rooks & (1 << 7)) != 0).to be true
    end

    it 'knows piece types at starting squares' do
      expect(board.piece_at(0)).to eq(:rook)
      expect(board.piece_at(4)).to eq(:king)
      expect(board.piece_at(60)).to eq(:king)
      expect(board.piece_at(59)).to eq(:queen)
    end
  end

  describe '#add_piece and #remove_piece' do
    it 'can add and remove a piece' do
      board = Chess::Board.start_position
      # clear a square and add a knight
      target = 16
      board.add_piece(Chess::WHITE, :knight, target)
      expect(board.white_knights & (1 << target)).not_to eq(0)
      board.remove_piece(Chess::WHITE, :knight, target)
      expect(board.white_knights & (1 << target)).to eq(0)
    end
  end
end
