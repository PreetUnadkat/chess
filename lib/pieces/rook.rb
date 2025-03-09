require_relative '../piece'
# Inherits from the Piece class.
class Rook < Piece
  def symbol
    color == 'W' ? "\u2656" : "\u265C" # White ♖, Black ♜
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
