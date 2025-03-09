require_relative '../piece'
# Inherits from the Piece class.
class Pawn < Piece
  def symbol
    color == 'W' ? "\u2659" : "\u265F" # ♙ / ♟  end
  end

  def raw_valid_moves_and_captures
    if @color == 'W'
      [[2, 0], [1, 0]]
    elsif @position[0] == 6
      [[-2, 0], [-1, 0]]
      [[1, 0]]
    end
  end
end
