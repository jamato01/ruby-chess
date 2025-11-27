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
      expect(game.history.length).to eq(1)
      expect(game.history.first).not_to be(initial_board)
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

describe 'Game save/load and forced results' do
  require 'tmpdir'

  it 'saves and loads a game' do
    game = Chess::Game.new(Chess::Board.start_position)
    path = File.join(Dir.tmpdir, "ruby_chess_test_save_#{Time.now.to_i}.sav")
    game.save(path)
    expect(File.exist?(path)).to be true
    loaded = Chess::Game.load(path)
    expect(loaded).to be_a(Chess::Game)
    # loaded game should have a board and position_count
    expect(loaded.position_count).to be >= 1
    # cleanup
    File.delete(path) if File.exist?(path)
  end

  it 'allows resign and force_draw and exposes winner/over?' do
    game = Chess::Game.new(Chess::Board.start_position)
    expect(game.over?).to be false
    # resigning should mark game over and set winner to opponent
    side = game.board.side_to_move
    game.resign(side)
    expect(game.over?).to be true
    expect(game.winner).not_to be_nil

    # force draw
    g2 = Chess::Game.new(Chess::Board.start_position)
    g2.force_draw
    expect(g2.over?).to be true
    expect(g2.winner).to be_nil
  end

  it 'reports threefold repetition when position count reaches 3' do
    game = Chess::Game.new(Chess::Board.start_position)
    # simulate two more occurrences of the same position
    key = game.board.position_key
    game.instance_variable_get(:@position_counts)[key] += 2
    expect(game.position_count).to be >= 3
    expect(game.threefold_repetition?).to be true
  end
end