require 'ruby2d'

module Chess
  module GUI
    class Ruby2DRenderer
      DEFAULT_SQUARE = 64
      LABEL_MARGIN = 28
      BOTTOM_MARGIN = 64

      WHITE_PIECES = {
        pawn: "♙", knight: "♘", bishop: "♗", rook: "♖", queen: "♕", king: "♔"
      }

      BLACK_PIECES = {
        pawn: "♟", knight: "♞", bishop: "♝", rook: "♜", queen: "♛", king: "♚"
      }

      def initialize(game, square_size: DEFAULT_SQUARE, debug: false)
        @game = game
        @board = game.board
        @square = square_size
        @selected = nil
        @highlights = []
        @rects = {}
        @piece_texts = {}
        @debug = debug
        @debug_text = nil
        @labels = []
        @controls = []
        @promotion_choices = nil
        @promotion_ui = []
        @board_x = LABEL_MARGIN
        @board_y = 0
      end

      def start
        raise "ruby2d gem not available. Please install 'ruby2d' to run GUI." unless defined?(Ruby2D)

        Window.set(title: "Ruby Chess", width: @square * 8 + @board_x + 8, height: @square * 8 + LABEL_MARGIN + BOTTOM_MARGIN + 16)

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
        # Draw squares with board offset so labels can live outside
        # clear previous squares
        @rects.values.each(&:remove) if @rects && !@rects.empty?
        @rects = {}
        (0..7).each do |rank|
          (0..7).each do |file|
            x = @board_x + file * @square
            y = @board_y + rank * @square
            color = (file + (7 - rank)).even? ? 'white' : 'purple'
            rect = Rectangle.new(x: x, y: y, width: @square, height: @square, color: color)
            sq = (7 - rank) * 8 + file
            @rects[sq] = rect
          end
        end
        draw_labels
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
          x = @board_x + file * @square + (@square * 0.15)
          y = @board_y + (7 - rank) * @square + (@square * 0.05)

          txt = Text.new(glyph, x: x, y: y, size: (@square * 0.8).to_i, color: 'black')
          @piece_texts[sq] = txt
        end
      end

      def draw_status
        @status_text&.remove
        if @game.forced_result
          fr = @game.forced_result
          if fr[:type] == :resign
            winner = fr[:winner] == Chess::WHITE ? 'White' : 'Black'
            msg = "Resignation — #{winner} wins"
          else
            msg = "Draw by agreement"
          end
        elsif @game.checkmate?
          winner = @board.side_to_move == Chess::WHITE ? 'Black' : 'White'
          msg = "Checkmate! #{winner} wins"
        elsif @game.stalemate?
          msg = "Stalemate — Draw"
        elsif @game.fifty_move_draw?
          msg = "Draw by 50-move rule"
        elsif @game.threefold_repetition?
          msg = "Draw by threefold repetition"
        else
          side = @board.side_to_move == Chess::WHITE ? 'White' : 'Black'
          in_check = @board.in_check?(@board.side_to_move) ? ' (in check)' : ''
          msg = "#{side} to move#{in_check}"
        end
        # place the to-move / status message above the control area
        status_y = @square * 8 + LABEL_MARGIN + 8
        @status_text = Text.new(msg, x: 10, y: status_y, size: 16, color: 'white')
        # If the game is over and a save file was associated with this game, delete it
        if @game.over? && @game.saved_path
          path = @game.saved_path
          begin
            if File.exist?(path)
              File.delete(path)
              msg2 = " (deleted save #{File.basename(path)})"
            else
              msg2 = " (save not found: #{File.basename(path)})"
            end
          rescue => e
            msg2 = " (failed to delete save: #{e.message})"
          end
          # clear saved_path so we don't attempt again
          @game.saved_path = nil if @game.respond_to?(:saved_path=)
          # refresh status text to include deletion result
          @status_text.remove
          @status_text = Text.new(msg + msg2, x: 10, y: @square * 8 + LABEL_MARGIN + 8, size: 16, color: 'white')
        end
        draw_controls
        # Debug overlay showing legal move count and stalemate/fifty-move status
        if @debug
          @debug_text&.remove
      dx = @board_x + @square * 8 - 360
      # put debug overlay next to the status message
      dy = status_y
      dbg = "position_count=#{@game.position_count} threefold=#{@game.threefold_repetition?}"
      @debug_text = Text.new(dbg, x: dx, y: dy, size: 14, color: 'yellow')
        end
      end

      def draw_controls
        # remove existing controls
        @controls.each do |c|
          c[:rect]&.remove
          c[:text]&.remove
        end
        @controls = []

        dx = @board_x + @square * 8 - 260
        # controls live at the very bottom area
        controls_y = @square * 8 + LABEL_MARGIN + BOTTOM_MARGIN - 28
        dy = controls_y
        bw = 80
        bh = 24
        gap = 8
        # Load button (loads most recent save)
        dx0 = dx - (bw + gap)
        rect0 = Rectangle.new(x: dx0, y: dy, width: bw, height: bh, color: [0, 0, 0, 0.7])
        txt0 = Text.new('Load', x: dx0 + 22, y: dy + 4, size: 14, color: 'white')
        @controls << { rect: rect0, text: txt0, action: :load }

        # Save button
        rect = Rectangle.new(x: dx, y: dy, width: bw, height: bh, color: [0, 0, 0, 0.7])
        txt = Text.new('Save', x: dx + 20, y: dy + 4, size: 14, color: 'white')
        @controls << { rect: rect, text: txt, action: :save }

        # Resign button
        dx2 = dx + bw + gap
        rect2 = Rectangle.new(x: dx2, y: dy, width: bw, height: bh, color: [0.4, 0, 0, 0.8])
        txt2 = Text.new('Resign', x: dx2 + 12, y: dy + 4, size: 14, color: 'white')
        @controls << { rect: rect2, text: txt2, action: :resign }

        # Force Draw button
        dx3 = dx2 + bw + gap
        rect3 = Rectangle.new(x: dx3, y: dy, width: bw, height: bh, color: [0, 0, 0.4, 0.8])
        txt3 = Text.new('Force Draw', x: dx3 + 6, y: dy + 4, size: 14, color: 'white')
        @controls << { rect: rect3, text: txt3, action: :force_draw }
      end

      def handle_click(x, y)
       # If game is over, ignore clicks on the board (prevents moves after checkmate/stalemate/draw)
        return if @game.over?

        # Check controls first (they live outside the board)
        if y > @board_y + @square * 8
          @controls.each do |c|
            rx = c[:rect].x
            ry = c[:rect].y
            rw = c[:rect].width
            rh = c[:rect].height
            if x >= rx && x <= (rx + rw) && y >= ry && y <= (ry + rh)
              case c[:action]
              when :load
                begin
                  files = Dir.glob('saves/*.sav')
                  if files.empty?
                    puts "No saves available to load"
                  else
                    path = files.max_by { |f| File.mtime(f) }
                    loaded = Chess::Game.load(path)
                    @game = loaded
                    @board = @game.board
                    puts "Loaded #{path}"
                    refresh_screen
                    return
                  end
                rescue => e
                  puts "Failed to load: #{e}"
                end
                refresh_screen
                return
              when :save
                begin
                  Dir.mkdir('saves') unless Dir.exist?('saves')
                  path = "saves/game_#{Time.now.strftime('%Y%m%d_%H%M%S')}.sav"
                  @game.save(path)
                  puts "Saved game to #{path}"
                rescue => e
                  puts "Failed to save: #{e}"
                end
                refresh_screen
                return
              when :resign
                @game.resign(@board.side_to_move)
                refresh_screen
                return
              when :force_draw
                @game.force_draw
                refresh_screen
                return
              end
            end
          end
        end

        # click in status area or outside board horizontally
        return if y > @board_y + @square * 8
        return if x < @board_x || x > (@board_x + @square * 8)

        # If a promotion picker is active, check its UI first
        if @promotion_choices
          @promotion_ui.each do |entry|
            rx = entry[:rect].x
            ry = entry[:rect].y
            rw = entry[:rect].width
            rh = entry[:rect].height
            if x >= rx && x <= (rx + rw) && y >= ry && y <= (ry + rh)
              move = entry[:move]
              @game.make_move(move)
              @board = @game.board
              clear_selection
              clear_promotion_ui
              refresh_screen
              return
            end
          end
        end

        file = ((x - @board_x) / @square).to_i
        rank = 7 - ((y - @board_y) / @square).to_i
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
            # If multiple promotions exist for this destination, show picker
            promo_moves = candidates.select(&:is_promotion?)
            # Show the promotion picker whenever there is at least one promotion move
            # (user requested explicit choice rather than auto-queen)
            if promo_moves.any?
              show_promotion_picker(sq, promo_moves)
              return
            end

            # Otherwise pick default (queen preferred) and apply
            move = prefer_promotion(candidates)
            @game.make_move(move)
            @board = @game.board
            clear_selection
            clear_promotion_ui
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

      def clear_promotion_ui
        @promotion_ui.each do |e|
          e[:rect]&.remove
          e[:text]&.remove
        end
        @promotion_ui = []
        @promotion_choices = nil
      end

      def show_promotion_picker(dest_sq, promo_moves)
        clear_promotion_ui
        @promotion_choices = { dest: dest_sq, moves: promo_moves }
        # center the promotion picker over the board
        w = 48
        h = 48
        gap = 12
        total_w = promo_moves.size * w + (promo_moves.size - 1) * gap
        board_total_w = @square * 8
        start_x = @board_x + (board_total_w - total_w) / 2.0
        center_y = @board_y + (board_total_w / 2.0)
        y = center_y - (h / 2.0)

        promo_moves.each_with_index do |m, idx|
          rx = start_x + idx * (w + gap)
          rect = Rectangle.new(x: rx, y: y, width: w, height: h, color: [0,0,0,0.95])
          piece_glyph = (@board.side_to_move == WHITE ? WHITE_PIECES[m.promotion] : BLACK_PIECES[m.promotion])
          txt = Text.new(piece_glyph, x: rx + (w * 0.18), y: y + (h * 0.05), size: 36, color: 'white')
          @promotion_ui << { rect: rect, text: txt, move: m }
        end
      end

      def refresh_screen
        draw_board
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

      def draw_labels
        # remove previous labels
        @labels.each do |entry|
          entry[:rect]&.remove
          entry[:text]&.remove
        end
        @labels = []

        # Files (a-h) along the bottom outside the board
        (0..7).each do |file|
          ch = ("a".ord + file).chr
          cx = @board_x + file * @square + (@square / 2)
          cy = @board_y + @square * 8 + 4
          bw = (@square * 0.6).to_i
          bh = 20
          bx = cx - (bw / 2)
          by = cy
          rect = Rectangle.new(x: bx, y: by, width: bw, height: bh, color: [0, 0, 0, 0.7])
          txt = Text.new(ch, x: cx - 6, y: by + 2, size: 14, color: 'white')
          @labels << { rect: rect, text: txt }
        end

        # Ranks (1-8) along the left outside the board
        (0..7).each do |r|
          label = (8 - r).to_s
          cx = 6
          cy = @board_y + r * @square + (@square / 2)
          bw = 20
          bh = 20
          rect = Rectangle.new(x: 2, y: cy - (bh / 2), width: bw, height: bh, color: [0, 0, 0, 0.7])
          txt = Text.new(label, x: cx, y: cy - 8, size: 14, color: 'white')
          @labels << { rect: rect, text: txt }
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
