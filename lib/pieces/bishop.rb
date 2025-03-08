require_relative '../piece'
# Inherits from the Piece class.
class Bishop < Piece
  def symbol
    color == 'W' ? "\u2657" : "\u265D" # ♗ / ♝
  end

  # Checks if the move to the given coordinates (x, y) is valid.
  def valid_move?(x, y)
    # Check if the move is valid
  end
end
