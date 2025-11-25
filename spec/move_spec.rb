require_relative '../lib/chess'

describe Chess::Move do
  describe '#initialize and predicates' do
    it 'creates a quiet non-promotion move' do
      move = Chess::Move.new(from: 12, to: 28)
      expect(move.from).to eq(12)
      expect(move.to).to eq(28)
      expect(move.flags).to eq(0)
      expect(move.is_promotion?).to be false
      expect(move.capture?).to be false
    end

    it 'supports promotion payloads and predicate' do
      move = Chess::Move.new(from: 48, to: 56, promotion: :queen)
      expect(move.is_promotion?).to be true
      expect(move.promotion).to eq(:queen)
    end
  end
end
