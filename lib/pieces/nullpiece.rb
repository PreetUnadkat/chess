require_relative '../piece'
# Inherits from the Piece class.
class Nullpiece < Piece
  def to_s
    '.'
  end
  # def symbol
  # ' '
  # end

  def raw_valid_moves
    nil
  end
end
