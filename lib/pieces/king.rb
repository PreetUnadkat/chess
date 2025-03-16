require_relative '../piece'
# Inherits from the Piece class.
class King < Piece
  attr_reader :castling_privilege

  def initialize(color, position)
    super
    @castling_privilege = true
    # @castling_privilege_left = true
  end

  def give_castling_privilege
    @castling_privilege = true
  end

  def revoke_castling_privilege
    @castling_privilege = false
  end

  def symbol
    color == 'W' ? "\u2654" : "\u265A" # ♔ / ♚
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
