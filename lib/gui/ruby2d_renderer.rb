require 'ruby2d'

module Chess
  module GUI
    class Ruby2DRenderer
      DEFAULT_SQUARE = 64

      WHITE_PIECES = {
        pawn: "♙", knight: "♘", bishop: "♗", rook: "♖", queen: "♕", king: "♔"
      }

      BLACK_PIECES = {
        pawn: "♟", knight: "♞", bishop: "♝", rook: "♜", queen: "♛", king: "♚"
      }

      def initialize(game, square_size: DEFAULT_SQUARE)
        @game = game
        @board = game.board
        @square = square_size
        @selected = nil
        @highlights = []
        @rects = {}
        @piece_texts = {}
      end

      def start
        raise "ruby2d gem not available. Please install 'ruby2d' to run GUI." unless defined?(Ruby2D)

        Window.set(title: "Ruby Chess", width: @square * 8, height: @square * 8 + 40)

        draw_board
        draw_pieces
        draw_status

        Ruby2D::Window.on :mouse_down do |event|
          handle_click(event.x, event.y)
        end

        show
      end

      def show
        Window.show
      end

      def draw_board
        # Draw squares
        (0..7).each do |rank|
          (0..7).each do |file|
            x = file * @square
            y = rank * @square
            color = (file + (7 - rank)).even? ? 'white' : 'purple'
            rect = Rectangle.new(x: x, y: y, width: @square, height: @square, color: color)
            sq = (7 - rank) * 8 + file
            @rects[sq] = rect
          end
        end
      end

      def draw_pieces
        # Remove existing piece texts
        @piece_texts.values.each(&:remove)
        @piece_texts.clear

        (0..63).each do |sq|
          piece = @board.piece_at(sq)
          next unless piece

          color = square_color_of_piece(sq)
          glyph = color == WHITE ? WHITE_PIECES[piece] : BLACK_PIECES[piece]

          file = sq % 8
          rank = sq / 8
          x = file * @square + (@square * 0.15)
          y = (7 - rank) * @square + (@square * 0.05)

          txt = Text.new(glyph, x: x, y: y, size: (@square * 0.8).to_i, color: 'black')
          @piece_texts[sq] = txt
        end
      end

      def draw_status
        @status_text&.remove
        if @game.checkmate?
          winner = @board.side_to_move == Chess::WHITE ? 'Black' : 'White'
          msg = "Checkmate! #{winner} wins"
        else
          side = @board.side_to_move == Chess::WHITE ? 'White' : 'Black'
          in_check = @board.in_check?(@board.side_to_move) ? ' (in check)' : ''
          msg = "#{side} to move#{in_check}"
        end
        @status_text = Text.new(msg, x: 10, y: @square * 8 + 8, size: 16, color: 'white')
      end

      def handle_click(x, y)
        return if y > @square * 8 # click in status area

        file = (x / @square).to_i
        rank = 7 - (y / @square).to_i
        sq = rank * 8 + file

        if @selected.nil?
          # Select a piece belonging to side to move
          piece = @board.piece_at(sq)
          if piece && piece_belongs_to_side?(sq, @board.side_to_move)
            @selected = sq
            highlight_moves_for_selected
          end
        else
          # Try to find a legal move from selected -> sq
          legal = MoveGenerator::Legal.generate(@board)
          candidates = legal.select { |m| m.from == @selected && m.to == sq }

          if candidates.any?
            # If promotion/captures produce multiple candidates choose queen first
            move = prefer_promotion(candidates)
            @game.make_move(move)
            @board = @game.board
            clear_selection
            refresh_screen
          else
            # Clicked elsewhere: clear or select new
            piece = @board.piece_at(sq)
            if piece && piece_belongs_to_side?(sq, @board.side_to_move)
              @selected = sq
              highlight_moves_for_selected
            else
              clear_selection
            end
          end
        end
      end

      def refresh_screen
        draw_pieces
        draw_status
        update_highlights
      end

      def clear_selection
        @selected = nil
        @highlights.each(&:remove)
        @highlights = []
      end

      def update_highlights
        @highlights.each(&:remove)
        @highlights = []
        # No persistent highlights besides last selection logic for now
      end

      def highlight_moves_for_selected
        @highlights.each(&:remove)
        @highlights = []
        legal = MoveGenerator::Legal.generate(@board)
        targets = legal.select { |m| m.from == @selected }.map(&:to)
        targets.each do |t|
          rect = @rects[t]
          next unless rect
          hl = Rectangle.new(x: rect.x, y: rect.y, width: rect.width, height: rect.height, color: [0, 1, 0, 0.25])
          @highlights << hl
        end
      end

      private

      def prefer_promotion(candidates)
        # prefer a non-nil promotion to queen, then any
        q = candidates.find { |m| m.promotion == :queen }
        return q if q
        candidates.first
      end

      def piece_belongs_to_side?(sq, color)
        bb = (color == Chess::WHITE ? @board.white_pieces : @board.black_pieces)
        (bb & (1 << sq)) != 0
      end

      def square_color_of_piece(sq)
        # Determine if piece at sq is white or black by checking bitboards
        ( (@board.white_pawns | @board.white_knights | @board.white_bishops | @board.white_rooks | @board.white_queens | @board.white_kings) & (1 << sq) ) != 0 ? WHITE : BLACK
      end
    end
  end
end
