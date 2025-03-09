require_relative '../piece'
# Inherits from the Piece class.
class Knight < Piece
  def symbol
    color == 'W' ? "\u2658" : "\u265E" # ♘ / ♞
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
