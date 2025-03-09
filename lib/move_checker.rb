require_relative 'board'
require_relative 'piece'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'
require_relative 'pieces/nullpiece'

class MoveChecker
  def initialize(boardo, piece)
    @piece = piece
    @grid = boardo.instance_variable_get(:@board)
    @cord = @piece.position
  end

  def possible_moves
    if @piece.is_a?(Pawn)
      pawn_moves
    elsif @piece.is_a?(Rook)
      rook_moves
    elsif @piece.is_a?(Knight)
      knight_moves
    elsif @piece.is_a?(Bishop)
      bishop_moves
    elsif @piece.is_a?(Queen)
      queen_moves
    elsif @piece.is_a?(King)
      king_moves
    else
      []
    end
  end

  private

  # assuming pawn is not promoted yet
  # ADD PROMOTION LATER
  def pawn_moves
    possible_moves = []
    if @piece.color == 'W'
      if @cord[1] > 0 && @cord[0] < 7
        possible_moves << [@cord[0] - 1, @cord[1] - 1] if @grid[@cord[0] - 1][@cord[1] - 1].color == 'B'
        possible_moves << [@cord[0] - 1, @cord[1] + 1] if @grid[@cord[0] - 1][@cord[1] + 1].color == 'B'
      elsif @cord[1] == 7
        possible_moves << [@cord[0] - 1, @cord[1] - 1] if @grid[@cord[0] - 1][@cord[1] - 1].color == 'B'
      elsif @cord[1] == 0
        possible_moves << [@cord[0] - 1, @cord[1] + 1] if @grid[@cord[0] - 1][@cord[1] - 1].color == 'B'
      end

      if @cord[0] == 6
        possible_moves << [@cord[0] - 1, @cord[1]] if @grid[@cord[0] - 1][@cord[1]].is_a?(Nullpiece)
        if @grid[@cord[0] - 1][@cord[1]].is_a?(Nullpiece) && @grid[@cord[0] - 2][@cord[1]].is_a?(Nullpiece)
          possible_moves << [@cord[0] - 2, @cord[1]]
        end
      elsif @cord[0] > 0
        possible_moves << [[@cord[0] - 1, @cord[1]]] if @grid[@cord[0] - 1][@cord[1]].is_a?(Nullpiece)
      end

    elsif @piece.color == 'B'
      if @cord[0] == 1
        possible_moves = [[@cord[0] + 1, @cord[1]], [@cord[0] + 2, @cord[1]]]
      elsif @cord < 7
        possible_moves = [[@cord[0] + 1, @cord[1]]]
      end
    end
    possible_moves
  end

  def rook_moves
    possible_moves = []
    (1..7).each do |i|
      next if i.zero?

      possible_moves << [@cord[0] + i, @cord[1]]
      possible_moves << [@cord[0], @cord[1] + i]
    end
    possible_moves
  end
  # private

  # def pawn_moves
  #   # Implement pawn move logic here
  # end

  # def rook_moves
  #   # Implement rook move logic here
  # end

  # def knight_moves
  #   # Implement knight move logic here
  # end

  # def bishop_moves
  #   # Implement bishop move logic here
  # end

  # def queen_moves
  #   # Implement queen move logic here
  # end

  # def king_moves
  #   # Implement king move logic here
  # end
end
# puts '====================='

boardo = Board.new
ok = boardo.instance_variable_get(:@board)
checker = MoveChecker.new(boardo, ok[6][6])
puts checker.possible_moves.inspect
boardo.move_piece([6, 6], [2, 6])
boardo.render_board
checker2 = MoveChecker.new(boardo, ok[2][6])
# puts ok[0][0].class
puts checker2.possible_moves.inspect
