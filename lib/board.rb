module Chess
  class Board
    attr_reader \
      :side_to_move,
      :castling_rights,
      :en_passant,
      :white_pawns, :white_knights, :white_bishops, :white_rooks, :white_queens, :white_kings,
      :black_pawns, :black_knights, :black_bishops, :black_rooks, :black_queens, :black_kings

    def initialize
      # initialize bitboards + metadata
    end

    def self.start_position
      # return Board with initial layout
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