require_relative '../piece'
# Inherits from the Piece class.
class Pawn < Piece
  def symbol
    color == 'W' ? "\u2659" : "\u265F" # ♙ / ♟  end
  end

  def promote
    puts 'Promote to (Q)ueen, (R)ook, (B)ishop, or (K)night?'
    choice = gets.chomp.upcase
    case choice
    when 'Q'
      Queen.new(@color, @board, @position)
    when 'R'
      Rook.new(@color, @board, @position)
    when 'B'
      Bishop.new(@color, @board, @position)
    when 'K'
      Knight.new(@color, @board, @position)
    else
      puts 'Invalid choice. Promoting to Queen by default.'
      Queen.new(@color, @board, @position)
    end
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
