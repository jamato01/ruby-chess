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

    def pieces(color)
      color == WHITE ? white_pieces : black_pieces
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

    def piece_at(square)
      bit = 1 << square

      if white_pawns & bit != 0 then return :pawn
      elsif white_knights & bit != 0 then return :knight
      elsif white_bishops & bit != 0 then return :bishop
      elsif white_rooks & bit != 0 then return :rook
      elsif white_queens & bit != 0 then return :queen
      elsif white_kings & bit != 0 then return :king
      elsif black_pawns & bit != 0 then return :pawn
      elsif black_knights & bit != 0 then return :knight
      elsif black_bishops & bit != 0 then return :bishop
      elsif black_rooks & bit != 0 then return :rook
      elsif black_queens & bit != 0 then return :queen
      elsif black_kings & bit != 0 then return :king
      else
        nil
      end
    end

    def opp(color)
      color == WHITE ? BLACK : WHITE
    end

    def add_piece(color, piece, square)
      bit = 1 << square

      case color
      when WHITE
        case piece
        when :pawn then white_pawns |= bit
        when :knight then white_knights |= bit
        when :bishop then white_bishops |= bit
        when :rook then white_rooks |= bit
        when :queen then white_queens |= bit
        when :king then white_kings |= bit
        end
      else
        case piece
        when :pawn then black_pawns |= bit
        when :knight then black_knights |= bit
        when :bishop then black_bishops |= bit
        when :rook then black_rooks |= bit
        when :queen then black_queens |= bit
        when :king then black_kings |= bit
        end
      end
    end

    def remove_piece(color, piece, square)
      bit = ~(1 << square)

      case color
      when WHITE
        case piece
        when :pawn then white_pawns &= bit
        when :knight then white_knights &= bit
        when :bishop then white_bishops &= bit
        when :rook then white_rooks &= bit
        when :queen then white_queens &= bit
        when :king then white_kings &= bit
        end
      else
        case piece
        when :pawn then black_pawns &= bit
        when :knight then black_knights &= bit
        when :bishop then black_bishops &= bit
        when :rook then black_rooks &= bit
        when :queen then black_queens &= bit
        when :king then black_kings &= bit
        end
      end
    end

    def clone
      Board.new(
        white_pawns: @white_pawns,
        white_knights: @white_knights,
        white_bishops: @white_bishops,
        white_rooks: @white_rooks,
        white_queens: @white_queens,
        white_king: @white_king,
        black_pawns: @black_pawns,
        black_knights: @black_knights,
        black_bishops: @black_bishops,
        black_rooks: @black_rooks,
        black_queens: @black_queens,
        black_king: @black_king,
        side_to_move: @side_to_move,
        castling_rights: @castling_rights,
        en_passant: @en_passant
      )
    end

    def in_check?(color)
      king_bb = (color == WHITE ? white_kings : black_kings)
      king_sq = Math.log2(king_bb).to_i

      MoveGenerator::Attacks.square_attacked?(self, king_sq, 1 - color)
    end
  end
end