require_relative '../piece'

# Inherits from the Piece class.
class Queen < Piece
  def symbol
    color == 'W' ? "\u2655" : "\u265B" # ♕ / ♛
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
