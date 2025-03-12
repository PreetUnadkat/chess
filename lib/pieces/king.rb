require_relative '../piece'
# Inherits from the Piece class.
class King < Piece
  def initialize(color, board, position)
    super
    @castling_privilege_right = true
    @castling_privilege_left = true
  end

  def revoke_castling_privilege(side)
    instance_variable_set("@castling_privilege_#{side}", false)
  end

  def symbol
    color == 'W' ? "\u2654" : "\u265A" # ♔ / ♚
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
