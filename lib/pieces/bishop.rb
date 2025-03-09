require_relative '../piece'
# Inherits from the Piece class.
class Bishop < Piece
  def symbol
    color == 'W' ? "\u2657" : "\u265D" # ♗ / ♝
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
