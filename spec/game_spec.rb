require_relative '../lib/game'
require_relative '../lib/move_applier'

describe Chess::Game do

  let(:initial_board) { double('Board') }
  let(:new_board) { double('new_board') }
  let(:move) { double('move') }
  subject(:game) { described_class.new(initial_board) }
  describe '#initialize' do
    # Only sets instance variables, no tests needed
  end

  describe '#make_move' do
    before do
      allow(Chess::MoveApplier).to receive(:apply).with(initial_board, move).and_return(new_board)
    end
    it 'stores previous board in history' do
      game.make_move(move)
      expect(game.history).to eq([initial_board])
    end

    it 'updates board with result of MoveApplier.apply' do
      game.make_move(move)
      expect(game.board).to eq(new_board)
    end

    it 'calls MoveApplier.apply with current board and move' do
      game.make_move(move)
      expect(Chess::MoveApplier).to have_received(:apply).with(initial_board, move)
    end
  end
end