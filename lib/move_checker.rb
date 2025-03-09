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

  def real_possible_moves
    puts '1'
    raw = raw_possible_moves
    puts '2'
    checks = [check_knight] + [check_pawn] + [check_qrb]
    puts '3'
    puts check_knight.inspect
    puts checks.inspect
    # allowed_due_to_pins = pinned
    # checks + [15_556]
  end

  def raw_possible_moves
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

  # should have done individually for bishop and rook but anyhow ig it will have to do!
  def check_qrb
    king_cord = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }.position
    # puts king_cord.inspect
    # Attacker cord finding can be more optimized but i will do it later!
    attacker_cord = []
    checker_cords = rook_moves(king_cord) + bishop_moves(king_cord) # we will check if any of the rook or bishop or queen is attacking the king in these and then join attacker and king to get 1 of disjoint cords!
    # puts checker_cords.inspect, 'hi'
    attacker_cords = []
    for i in checker_cords
      next unless @grid[i[0]][i[1]].color != @piece.color and [Rook, Queen, Bishop].include?(@grid[i[0]][i[1]].class)

      attacker_cords << i
      # puts attacker_cords.inspect, 'hi'
      next
    end
    # return all cords connecting attacker and king
    return [] if attacker_cords.empty?

    paths = []
    for attacker_cord in attacker_cords

      direction = [(attacker_cord[0] - king_cord[0]) <=> 0, (attacker_cord[1] - king_cord[1]) <=> 0]
      path = []
      current_cord = [king_cord[0] + direction[0], king_cord[1] + direction[1]]

      until current_cord == attacker_cord
        path << current_cord
        current_cord = [current_cord[0] + direction[0], current_cord[1] + direction[1]]
      end
      paths << path + [attacker_cord]
    end
    paths
  end

  def check_knight
    king_cord = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }.position
    attacker_cord = []
    # two knights can never attack so cord
    checker_cord = knight_moves(king_cord) # we will check if any of the rook or bishop or queen is attacking the king in these and then join attacker and king to get 1 of disjoint cords!
    # puts checker_cords.inspect, 'hi'
    attacker_cord = []
    for i in checker_cord
      next unless @grid[i[0]][i[1]].color != @piece.color and Knight == (@grid[i[0]][i[1]].class)

      attacker_cord << i
      # puts attacker_cords.inspect, 'hi'
      break # as only 1 knigh possible
    end
    # return all cords connecting attacker and king
    return [] if attacker_cord.empty?

    attacker_cord
  end

  def check_pawn
    king_cord = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }.position
    attacker_cord = []
    # two pawns can never attack so cord
    i = @grid[king_cord[0]][king_cord[1]].color == 'B' ? 1 : -1
    x = king_cord[0]
    y = king_cord[1]
    lis = [[x + i, y - 1], [x + i, y + 1], [x + 2 * i, y - 1], [x + 2 * i, y + 1]]
    for goo in lis
      attacker_cord << goo if goo[0] >= 0 and goo[0] < 8 and goo[1] >= 0 and goo[1] < 8
    end
    # puts checker_cords.inspect, 'hi'

    return [] if attacker_cord.empty?

    checker_cords = []
    for i in attacker_cord
      next unless @grid[i[0]][i[1]].color != @piece.color and Pawn == (@grid[i[0]][i[1]].class)

      checker_cords << i
      # puts attacker_cords.inspect, 'hi'
      break # as only 1 pawn possible
    end
    # return all cords connecting attacker and king
    checker_cords
  end

  # same code as check but after removing the selected piece ie making grid with no selected piece!
  def pinned
    selected_piece_sq = @grid[@cord[0]][@cord[1]]
    @grid[@cord[0]][@cord[1]] = Nullpiece.new(nil, @boardo, @cord)

    # dup_grid = @grid.map(&:dup)
    # dup_grid[@cord[0]][@cord[1]] = Nullpiece.new(nil, @boardo, @cord)
    # puts dup_grid[@cord[0]][@cord[1]].position
    king_cord = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }.position
    # puts king_cord.inspect
    # Attacker cord finding can be more optimized but i will do it later!
    attacker_cord = []
    checker_cords = rook_moves(king_cord) + bishop_moves(king_cord) # we will check if any of the rook or bishop or queen is attacking the king
    puts checker_cords.inspect
    puts @cord.inspect
    unless checker_cords.include?(@cord)
      @grid[@cord[0]][@cord[1]] = selected_piece_sq
      return []
    end
    @grid[@cord[0]][@cord[1]] = selected_piece_sq

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

  private

  # assuming pawn is not promoted yet
  # ADD PROMOTION LATER
  def pawn_moves(cords)
    possible_moves = []
    if @piece.color == 'W'
      if cords[1] > 0 && cords[0] < 7
        possible_moves << [cords[0] - 1, cords[1] - 1] if @grid[cords[0] - 1][cords[1] - 1].color == 'B'
        possible_moves << [cords[0] - 1, cords[1] + 1] if @grid[cords[0] - 1][cords[1] + 1].color == 'B'
      elsif cords[1] == 7
        possible_moves << [cords[0] - 1, cords[1] - 1] if @grid[cords[0] - 1][cords[1] - 1].color == 'B'
      elsif cords[1] == 0
        possible_moves << [cords[0] - 1, cords[1] + 1] if @grid[cords[0] - 1][cords[1] - 1].color == 'B'
      end

      if cords[0] == 6
        possible_moves << [cords[0] - 1, cords[1]] if @grid[cords[0] - 1][cords[1]].is_a?(Nullpiece)
        if @grid[cords[0] - 1][cords[1]].is_a?(Nullpiece) && @grid[cords[0] - 2][cords[1]].is_a?(Nullpiece)
          possible_moves << [cords[0] - 2, cords[1]]
        end
      elsif cords[0] > 0
        possible_moves << [[cords[0] - 1, cords[1]]] if @grid[cords[0] - 1][cords[1]].is_a?(Nullpiece)
      end

    elsif @piece.color == 'B'
      if cords[0] == 1
        possible_moves = [[cords[0] + 1, cords[1]], [cords[0] + 2, cords[1]]]
      elsif cords < 7
        possible_moves = [[cords[0] + 1, cords[1]]]
      end
    end
    possible_moves
  end

  def rook_moves(cords)
    # puts cords.inspect
    possible_moves = []
    # moves along file!
    (1..2).each do |j|
      (1..7).each do |i|
        i = -i if j == 2
        # puts "i: #{i}"
        break if cords[0] + i < 0 || cords[0] + i > 7

        interested_square = @grid[cords[0] + i][cords[1]]
        move_check = [cords[0] + i, cords[1]]

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
        break if cords[1] + i < 0 || cords[1] + i > 7

        interested_square = @grid[cords[0]][cords[1] + i]
        move_check = [cords[0], cords[1] + i]

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
    # puts cords.inspect
    # FIXED -> ok here vars are a bit confusing i hope it doesnt break in future but i think we will mahe to make it more effcient! -> FIXED!
    possible_moves = []
    # just generating 4 directions (1,1) (-1,1) (1,-1) (-1,-1)
    lis = [[1, 1], [-1, 1], [1, -1], [-1, -1]]
    (1..4).each do |dirn|
      (1..7).each do |distance|
        up = distance * lis[dirn - 1][0]
        right = distance * lis[dirn - 1][1]
        # puts "i: #{i}"
        break if cords[0] + up < 0 || cords[0] + up > 7
        break if cords[1] + right < 0 || cords[1] + right > 7

        interested_square = @grid[cords[0] + up][cords[1] + right]
        move_check = [cords[0] + up, cords[1] + right]

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
      next if cords[0] + up < 0 || cords[0] + up > 7
      next if cords[1] + right < 0 || cords[1] + right > 7
      next if @grid[cords[0] + up][cords[1] + right].color == @piece.color

      possible_moves << [cords[0] + up, cords[1] + right]
    end
    possible_moves
  end

  def king_moves(cords)
    lis = [[1, 0], [0, 1], [-1, 0], [0, -1], [1, 1], [-1, 1], [1, -1], [-1, -1]]
    possible_moves = []
    lis.each do |i|
      up = i[0]
      right = i[1]
      next if cords[0] + up < 0 || cords[0] + up > 7
      next if cords[1] + right < 0 || cords[1] + right > 7
      next if @grid[cords[0] + up][cords[1] + right].color == @piece.color

      possible_moves << [cords[0] + up, cords[1] + right]
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
puts 'Final'
boardo = Board.new
ok = boardo.instance_variable_get(:@board)
checker = MoveChecker.new(boardo, ok[7][4])
# puts checker.real_possible_moves
# puts checker.pinned
boardo.move_piece([7, 4], [5, 4])
boardo.move_piece([0, 2], [2, 1])
boardo.move_piece([7, 1], [4, 5])
boardo.move_piece([0, 5], [2, 7])
boardo.move_piece([0, 3], [2, 4])
boardo.move_piece([0, 6], [3, 5])
boardo.move_piece([1, 6], [4, 3])
boardo.render_board
checker2 = MoveChecker.new(boardo, ok[4][5])
puts checker2.real_possible_moves.inspect
# puts checker2.check_qrb.inspect
# puts checker2.check_knight.inspect
# puts checker2.check_pawn.inspect

# puts '====================='
# puts 'PINNED CHECKS'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[7][4])
# puts checker.possible_moves.inspect
# # puts checker.pinned
# boardo.move_piece([7, 4], [5, 4])
# boardo.move_piece([0, 2], [2, 1])
# boardo.move_piece([7, 1], [4, 3])
# boardo.move_piece([0, 5], [2, 7])
# boardo.move_piece([0, 3], [2, 4])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[4][3])
# puts checker2.pinned.inspect
# puts checker2.check_qrb.inspect

# # puts ok[0][0].class
# # puts checker2.possible_moves.inspect
# puts '====================='

# puts '====================='
# puts 'PINNED CHECKS'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[7][4])
# puts checker.possible_moves.inspect
# puts checker.pinned
# boardo.move_piece([7, 4], [5, 4])
# boardo.move_piece([0, 2], [2, 1])
# boardo.move_piece([7, 1], [4, 5])
# boardo.move_piece([0, 5], [2, 7])
# boardo.move_piece([0, 3], [2, 4])
# boardo.move_piece([0, 6], [3, 5])
# boardo.move_piece([1, 6], [4, 3])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[4][5])
# puts checker2.pinned.inspect
# puts checker2.check_qrb.inspect
# puts checker2.check_knight.inspect
# puts checker2.check_pawn.inspect

# puts ok[0][0].class
# puts checker2.possible_moves.inspect
# puts '====================='

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
