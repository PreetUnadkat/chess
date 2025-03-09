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
    @boardo = boardo
    # @cord IS [ROW, COL] I.E. [8, 0] IS A1
    @cord = @piece.position
  end

  def check_qrb
    king_cord = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }.position
    # puts king_cord.inspect
    # Attacker cord finding can be more optimized but i will do it later!
    attacker_cord = []
    checker_cords = rook_moves(king_cord) + bishop_moves(king_cord) # we will check if any of the rook or bishop or queen is attacking the king in these and then join attacker and king to get 1 of disjoint cords!
    puts checker_cords.inspect, 'hi'
    for i in checker_cords
      next unless @grid[i[0]][i[1]].color != @piece.color and [Rook, Queen, Bishop].include?(@grid[i[0]][i[1]].class)

      attacker_cord = i
      puts attacker_cord.inspect
      break
    end
    # return all cords connecting attacker and king
    return [] if attacker_cord.empty?

    direction = [(attacker_cord[0] - king_cord[0]) <=> 0, (attacker_cord[1] - king_cord[1]) <=> 0]
    path = []
    current_cord = [king_cord[0] + direction[0], king_cord[1] + direction[1]]

    until current_cord == attacker_cord
      path << current_cord
      current_cord = [current_cord[0] + direction[0], current_cord[1] + direction[1]]
    end

    path + [attacker_cord]
  end

  # same code as check but after removing the selected piece ie making grid with no selected piece!
  def pinned
    dup_grid = @grid.map(&:dup)
    dup_grid[@cord[0]][@cord[1]] = Nullpiece.new(nil, @boardo, @cord)
    puts dup_grid[@cord[0]][@cord[1]].position
    king_cord = dup_grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }.position
    # puts king_cord.inspect
    # Attacker cord finding can be more optimized but i will do it later!
    attacker_cord = []
    checker_cords = rook_moves(@cords) + bishop_moves(@cords) # we will check if any of the rook or bishop or queen is attacking the king
    # in these and then join attacker and king to get 1 of the disjoint cords sets!
    for i in checker_cords
      next unless @grid[i[0]][i[1]].color != @piece.color and [Rook, Queen, Bishop].include?(@grid[i[0]][i[1]].class)

      attacker_cord = i
      # puts attacker_cord.inspect
      break
    end
    # return all cords connecting attacker and king
    return [] if attacker_cord.empty?

    direction = [(attacker_cord[0] - king_cord[0]) <=> 0, (attacker_cord[1] - king_cord[1]) <=> 0]
    path = []
    current_cord = [king_cord[0] + direction[0], king_cord[1] + direction[1]]

    until current_cord == attacker_cord
      path << current_cord
      current_cord = [current_cord[0] + direction[0], current_cord[1] + direction[1]]
    end

    path + [attacker_cord]
  end
  # we will find all lines through our king and check if any of the rook, bishop or queen is on that line
  # if yes we will then take intersection of that line and our possible moves
  # further i will check if the king is attacked by knight or pawn if so i will force to capture that piece

  def possible_moves
    if @piece.is_a?(Pawn)
      pawn_moves(@cord)
    elsif @piece.is_a?(Rook)
      rook_moves(@cord)
    elsif @piece.is_a?(Knight)
      knight_moves(@cord)
    elsif @piece.is_a?(Bishop)
      bishop_moves(@cord)
    elsif @piece.is_a?(Queen)
      bishop_moves(@cord) + rook_moves(@cord)
    elsif @piece.is_a?(King)
      king_moves(@cord)
    else
      []
    end
  end

  private

  # assuming pawn is not promoted yet
  # ADD PROMOTION LATER
  def pawn_moves(cords)
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

  def rook_moves(cords)
    # puts @cord.inspect
    possible_moves = []
    # moves along file!
    (1..2).each do |j|
      (1..7).each do |i|
        i = -i if j == 2
        # puts "i: #{i}"
        break if @cord[0] + i < 0 || @cord[0] + i > 7

        interested_square = @grid[@cord[0] + i][@cord[1]]
        move_check = [@cord[0] + i, @cord[1]]

        if !interested_square.is_a?(Nullpiece)
          break unless interested_square.color != @piece.color # if the piece is an enemy piece

          possible_moves << move_check
          break

        else
          possible_moves << move_check
        end
      end
    end
    # moves along rank!
    (1..2).each do |j|
      (1..7).each do |i|
        i = -i if j == 2
        break if @cord[1] + i < 0 || @cord[1] + i > 7

        interested_square = @grid[@cord[0]][@cord[1] + i]
        move_check = [@cord[0], @cord[1] + i]

        if !interested_square.is_a?(Nullpiece)
          break unless interested_square.color != @piece.color # if the piece is an enemy piece

          possible_moves << move_check
          break

        else
          possible_moves << move_check
        end
      end
    end

    possible_moves
  end

  def bishop_moves(cords)
    # puts @cord.inspect
    # FIXED -> ok here vars are a bit confusing i hope it doesnt break in future but i think we will mahe to make it more effcient! -> FIXED!
    possible_moves = []
    # just generating 4 directions (1,1) (-1,1) (1,-1) (-1,-1)
    lis = [[1, 1], [-1, 1], [1, -1], [-1, -1]]
    (1..4).each do |dirn|
      (1..7).each do |distance|
        up = distance * lis[dirn - 1][0]
        right = distance * lis[dirn - 1][1]
        # puts "i: #{i}"
        break if @cord[0] + up < 0 || @cord[0] + up > 7
        break if @cord[1] + right < 0 || @cord[1] + right > 7

        interested_square = @grid[@cord[0] + up][@cord[1] + right]
        move_check = [@cord[0] + up, @cord[1] + right]

        if !interested_square.is_a?(Nullpiece)
          break unless interested_square.color != @piece.color # if the piece is an enemy piece

          possible_moves << move_check
          break

        else
          possible_moves << move_check
        end
      end
    end
    possible_moves
  end

  def knight_moves(cords)
    lis = [[1, 2], [2, 1], [-1, 2], [-2, 1], [1, -2], [2, -1], [-1, -2], [-2, -1]]
    possible_moves = []
    lis.each do |i|
      up = i[0]
      right = i[1]
      next if @cord[0] + up < 0 || @cord[0] + up > 7
      next if @cord[1] + right < 0 || @cord[1] + right > 7
      next if @grid[@cord[0] + up][@cord[1] + right].color == @piece.color

      possible_moves << [@cord[0] + up, @cord[1] + right]
    end
    possible_moves
  end

  def king_moves(cords)
    lis = [[1, 0], [0, 1], [-1, 0], [0, -1], [1, 1], [-1, 1], [1, -1], [-1, -1]]
    possible_moves = []
    lis.each do |i|
      up = i[0]
      right = i[1]
      next if @cord[0] + up < 0 || @cord[0] + up > 7
      next if @cord[1] + right < 0 || @cord[1] + right > 7
      next if @grid[@cord[0] + up][@cord[1] + right].color == @piece.color

      possible_moves << [@cord[0] + up, @cord[1] + right]
    end
    possible_moves
  end

  # Is the piece pinned and if yes along which direction?
  # def pinned
  #   dup_grid = @grid.map(&:dup)
  #   dup_grid[@cord[0]][@cord[1]] = Nullpiece.new(nil, @boardo, @cord)
  #   king_cord = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }.position
  #   puts king_cord.inspect
  # end
end

puts '====================='
puts 'PINNED CHECKS'
boardo = Board.new
ok = boardo.instance_variable_get(:@board)
checker = MoveChecker.new(boardo, ok[7][4])
puts checker.possible_moves.inspect
# puts checker.pinned
boardo.move_piece([7, 4], [5, 4])
boardo.move_piece([0, 2], [2, 1])
boardo.move_piece([7, 1], [4, 3])
boardo.move_piece([0, 3], [2, 4])
boardo.render_board
checker2 = MoveChecker.new(boardo, ok[4][3])
puts checker2.pinned.inspect
puts checker2.check_qrb.inspect

# puts ok[0][0].class
# puts checker2.possible_moves.inspect
puts '====================='

# puts '====================='
# puts 'PAWN MOVES'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[6][6])
# puts checker.possible_moves.inspect
# puts checker.pinned
# boardo.move_piece([6, 6], [3, 6])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[3][6])
# # puts ok[0][0].class
# puts checker2.possible_moves.inspect
# puts '====================='

# puts '====================='
# puts 'ROOK MOVES'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)

# checker = MoveChecker.new(boardo, ok[7][7])
# puts checker.possible_moves.inspect
# boardo.move_piece([7, 7], [5, 7])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[5][7])
# # puts ok[0][0].class
# puts checker2.possible_moves.inspect
# puts '====================='

# puts '====================='
# puts 'BISHOP MOVES'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[7][5])
# puts checker.possible_moves.inspect
# boardo.move_piece([7, 5], [1, 5])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[1][5])
# # puts ok[0][0].class
# puts checker2.possible_moves.inspect
# puts '====================='

# puts '====================='
# puts 'QUEEN MOVES lol'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[7][3])
# puts checker.possible_moves.inspect
# boardo.move_piece([7, 3], [5, 3])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[5][3])
# # puts ok[0][0].class
# puts checker2.possible_moves.inspect
# puts '====================='

# puts '====================='
# puts 'KNIGHT MOVES'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[7][6])
# puts checker.possible_moves.inspect
# boardo.move_piece([7, 6], [1, 5])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[1][5])
# # puts ok[0][0].class
# puts checker2.possible_moves.inspect
# puts '====================='

# puts '====================='
# puts 'KING MOVES'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[7][4])
# puts checker.possible_moves.inspect
# boardo.move_piece([7, 4], [6, 4])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[6][4])
# # puts ok[0][0].class
# puts checker2.possible_moves.inspect
# puts '====================='
