require_relative 'piece'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'
require_relative 'pieces/nullpiece'

class Board
  def initialize(variant = 'standard')
    @board = Array.new(8) { Array.new(8) }
    @variant = variant
    populate_board
  end

  def populate_board
    (0..7).each do |row|
      (0..7).each do |col|
        @board[row][col] = Nullpiece.new(nil, self, [row, col])
      end
    end
    # Adding only standard right now.
    pieces = {
      rook: [Rook, [[0, 0], [0, 7], [7, 0], [7, 7]]],
      knight: [Knight, [[0, 1], [0, 6], [7, 1], [7, 6]]],
      bishop: [Bishop, [[0, 2], [0, 5], [7, 2], [7, 5]]],
      queen: [Queen, [[0, 3], [7, 3]]],
      king: [King, [[0, 4], [7, 4]]],
      pawn: [Pawn, (0..7).map { |i| [1, i] } + (0..7).map { |i| [6, i] }]
    }

    pieces.each_value do |(klass, positions)|
      positions.each do |pos|
        color = pos[0] < 2 ? 'B' : 'W'
        @board[pos[0]][pos[1]] = klass.new(color, self, [pos[0], pos[1]])
      end
    end
  end

  def render_board
    puts "\n  a b c d e f g h"
    @board.each_with_index do |row, i|
      print "#{8 - i} " # Row numbers (from 8 to 1)
      row.each do |piece|
        print piece.is_a?(Nullpiece) ? '. ' : "#{piece} "
      end
      puts
    end
  end

  def move_piece(start_pos, end_pos)
    piece = @board[start_pos[0]][start_pos[1]]
    @board[end_pos[0]][end_pos[1]] = piece
    @board[start_pos[0]][start_pos[1]] = Nullpiece.new(nil, self, start_pos)
    piece.position = end_pos
  end
end

# board = Board.new
# board.render_board
# board.move_piece([1, 0], [0, 0])

# board.render_board
# print board.instance_variable_get(:@board)[0][0]
