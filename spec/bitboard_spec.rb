require_relative '../lib/bitboard'
describe Chess::Bitboard do
  describe '#pop_lsb(bb)' do
    context 'when there is only one piece on the bitboard' do
      it 'returns just that piece and 0' do
        bitboard = 0x0000000000000008
        remaining_board, square = Chess::Bitboard.pop_lsb(bitboard)
        expect(remaining_board).to eq(0)
        expect(square).to eq(3)
      end
    end

    context 'when there are multiple pieces on the bitboard' do
      it 'returns the lowest bit piece and the rest of the bitboard' do
        bitboard = 0x000000000000FF00
        remaining_board, square = Chess::Bitboard.pop_lsb(bitboard)
        expect(remaining_board).to eq(65024)
        expect(square).to eq(8)
      end
    end
  end

  describe '#each_bit(bb)' do
    context 'when there is only one piece on the bitboard' do
      it 'yields only one bit' do
        bitboard = 0x0000000000000008
        yielded = []
        Chess::Bitboard.each_bit(bitboard) { |square| yielded << square }

        expect(yielded).to eq([3])
      end
    end

    context 'when there are 8 pieces on the bitboard' do
      it 'yields all 8 pieces in order of bits, smallest to largest' do
        bitboard = 0x000000000000FF00
        yielded = []
        Chess::Bitboard.each_bit(bitboard) { |square| yielded << square }

        expect(yielded).to eq([8, 9, 10, 11, 12, 13, 14, 15])
      end
    end
  end
end