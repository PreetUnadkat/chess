require_relative '../piece'
# Inherits from the Piece class.
class Nullpiece < Piece
  def symbol
    ' '
  end

  # Checks if the move to the given coordinates (x, y) is valid.
  def valid_move?(x, y)
    # Check if the move is valid
  end
end
