require_relative 'piece'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'

class Board
  def initialize(variant = standard)
    @board = Array.new(8) { Array.new(8) }
    @variant = variant
    populate_board
  end

  def populate_board
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
        @board[pos[0]][pos[1]] = klass.new
      end
    end
  end

  def print
    @board.each do |row|
      row.each do |piece|
        print piece
      end
      puts
    end
  end
end
