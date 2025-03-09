require_relative '../piece'
# Inherits from the Piece class.
class King < Piece
  def symbol
    color == 'W' ? "\u2654" : "\u265A" # ♔ / ♚
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
