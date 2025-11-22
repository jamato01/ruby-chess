module Chess
  class Board
    attr_reader \
      :side_to_move,
      :castling_rights,
      :en_passant,
      :white_pawns, :white_knights, :white_bishops, :white_rooks, :white_queens, :white_kings,
      :black_pawns, :black_knights, :black_bishops, :black_rooks, :black_queens, :black_kings

    def initialize(white_pawns:, white_knights:, white_bishops:, white_rooks:, white_queens:, white_kings:, black_pawns:, black_knights:, black_bishops:, black_rooks:, black_queens:, black_kings:, side_to_move:, castling_rights:, en_passant:)
      # initialize bitboards + metadata
      @white_pawns = white_pawns,
      @white_knights = white_knights,
      @white_bishops = white_bishops,
      @white_rooks = white_rooks,
      @white_queens = white_queens,
      @white_kings = white_kings,
      @black_pawns = black_pawns,
      @black_knights = black_knights,
      @black_bishops = black_bishops,
      @black_rooks = black_rooks,
      @black_queens = black_queens,
      @black_kings = black_kings,
      @side_to_move = side_to_move,
      @castling_rights = castling_rights,
      @en_passant = en_passant
    end

    def self.start_position
      # return Board with initial layout
      new(
        white_pawns:   0x000000000000FF00,
        white_knights: 0x0000000000000042,
        white_bishops: 0x0000000000000024,
        white_rooks:   0x0000000000000081,
        white_queens:  0x0000000000000008,
        white_kings:   0x0000000000000010,
        black_pawns:   0x00FF000000000000,
        black_knights: 0x4200000000000000,
        black_bishops: 0x2400000000000000,
        black_rooks:   0x0800000000000000,
        black_queens:  0x0800000000000000,
        black_kings:   0x1000000000000000,
        side_to_move: Chess::WHITE,
        castling_rights: 0b1111,
        en_passant: nil
      )
    end

    def white_pieces
      white_pawns | white_knights | white_bishops | white_rooks | white_queens | white_kings
    end

    def black_pieces
      black_pawns | black_knights | black_bishops | black_rooks | black_queens | black_kings
    end

    def all_pieces
      white_pieces | black_pieces
    end
  end
end