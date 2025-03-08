# Generic chess piece.
# To be subclassed by specific types of chess pieces.
#
# Attributes:
#   @color [Symbol] the color of the piece (:white or :black)
#   @board [Board] the board the piece is on
#   @position [Array<Integer>] the current position of the piece on the board
#
# Methods:
#   initialize(color, board, position) - Initializes a new Piece with the given color, board, and position.
#   to_s - Returns a string representation of the piece.
#   empty? - Returns false, indicating the piece is not empty.
#   valid_moves - Returns an array of valid moves for the piece, excluding moves that would place the piece in check.
#   move_into_check?(end_pos) - Returns true if moving the piece to the given position would place the piece in check.
#   symbol - Raises NotImplementedError. Should be implemented by subclasses to return the symbol representing the piece.
#
# Private Methods:
#   move_dirs - Raises NotImplementedError. Should be implemented by subclasses to return the directions the piece can move.
class Piece
  attr_reader :color, :board
  attr_accessor :position

  # postion in [x, y] format
  def initialize(color, board, position)
    @color = color
    @board = board
    @position = position
  end

  def to_s
    if @color == 'W'
      "\e[97m#{symbol}\e[0m"
    elsif @color == 'B'
      "\e[31m#{symbol}\e[0m"
    end
  end

  def raw_valid_moves
    raise NotImplementedError
  end

  def valid_moves(raw_valid_moves)
    raise NotImplementedError
  end

  def move_into_check?(end_pos)
    dup_board = board.dup
    dup_board.move_piece!(position, end_pos)
    dup_board.in_check?(color)
  end

  def symbol
    raise NotImplementedError
  end
end
