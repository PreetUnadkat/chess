require_relative '../piece'
# Inherits from the Piece class.
class King < Piece
  attr_reader :castling_privilege

  # Only will be able to castle if @castling_priveledege == 0 that is havent moved a single time

  def initialize(color, position)
    super
    @castling_privilege = 0
    # @castling_privilege_left = true
  end

  def give_castling_privilege
    @castling_privilege -= 1 if @castling_privilege > 0
  end

  def revoke_castling_privilege
    @castling_privilege += 1
  end

  def symbol
    color == 'W' ? "\u2654" : "\u265A" # ♔ / ♚
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
