require_relative '../piece'
# Inherits from the Piece class.
class Rook < Piece
  attr_reader :castling_privilege

  def initialize(color, position)
    super
    @castling_privilege = true
  end

  def revoke_castling_privilege
    @castling_privilege = false
  end

  def symbol
    color == 'W' ? "\u2656" : "\u265C" # White ♖, Black ♜
  end

  def raw_valid_moves
    raise NotImplementedError
  end
end
