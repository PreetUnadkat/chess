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
    # @changer = @piece.color == 'B' ? -1 : 1
    # @cord IS [ROW, COL] I.E. [8, 0] IS A1
    @cord = @piece.position
  end

  def real_possible_moves(color)
    return [] if @piece.is_a?(Nullpiece)
    return [] if @piece.color != color
    return selected_king_moves if @piece.is_a?(King)

    raw = raw_possible_moves
    pin = pinned
    # puts pin.inspect
    checks = [check_knight] + [check_pawn] + check_qrb + [pin]
    # puts raw_possible_moves.inspect
    # puts checks.inspect, '31'
    # puts raw.inspect, '32'
    intersections = raw_possible_moves.dup # Start with all possible moves
    for i in checks
      # puts i.inspect
      intersections &= i if i != []
      # puts intersections.inspect

      # puts i.inspect
      # puts raw_possible_moves.inspect
    end

    intersections
    # raw_possible_moves
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

  # which color is in check
  def check(color = @piece.color)
    king_piece = @boardo.find_king(@piece.color)
    @grid.flatten.each do |piecee|
      next if piecee.color != king_piece.color || piecee.is_a?(Nullpiece) || piecee.is_a?(King)
      return true if MoveChecker.new(@boardo, piecee).real_possible_moves(@piece.color).include?(king_piece.position)
    end
    false
  end

  # should have done individually for bishop and rook but anyhow ig it will have to do!
  def check_qrb
    king_piece = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }
    return [] if king_piece.nil?

    king_cord = king_piece.position
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
    king_piece = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }
    return [] if king_piece.nil?

    king_cord = king_piece.position
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
    king_piece = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }
    return [] if king_piece.nil?

    king_cord = king_piece.position
    attacker_cord = []
    # two pawns can never attack so cord
    i = @grid[king_cord[0]][king_cord[1]].color == 'B' ? 1 : -1
    x = king_cord[0]
    y = king_cord[1]
    lis = [[x + i, y - 1], [x + i, y + 1]] # DELETED THIS , [x + 2 * i, y - 1], [x + 2 * i, y + 1]
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
    king_piece = @grid.flatten.find { |piece| piece.is_a?(King) && piece.color == @piece.color }
    return [] if king_piece.nil?

    king_cord = king_piece.position

    # puts king_cord.inspect
    # Attacker cord finding can be more optimized but i will do it later!
    attacker_cord = []
    checker_cords = rook_moves(king_cord) + bishop_moves(king_cord) # we will check if any of the rook or bishop or queen is attacking the king
    # puts checker_cords.inspect
    # puts @cord.inspect
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

  def check_mate
    return false if selected_king_moves(true) != []

    check
  end

  private

  def selected_king_moves(want_to_check_for_checkmate = false)
    raw = raw_possible_moves + [@cord]
    # puts raw.inspect, 'selected_king_moves'
    anso = []
    # puts raw.inspect, 'selected_king_moves'
    for possible_move in raw
      new_board = Marshal.load(Marshal.dump(@boardo)) # This marshall dupe is 7000 TIMES SLOWER than normal dupe (which wont work here obv)
      new_board.move_piece(@cord, possible_move)
      # new_board.render_board

      new_grid = new_board.instance_variable_get(:@board)
      # new_board.render_board
      # puts @grid.flatten.length, '221'
      for piecee in new_grid.flatten

        flag = 0
        next unless piecee.color != @piece.color && !piecee.is_a?(Nullpiece)

        # puts MoveChecker.new(@boardo, piecee).raw_possible_moves.inspect, '220'
        if MoveChecker.new(new_board, piecee).raw_possible_moves.include?(possible_move)
          flag = 1
          break
        end
      end
      anso << possible_move if flag == 0
      # puts anso.inspect, '225'
    end
    # puts raw[-1].inspect, @cord.inspect, '227'
    # @boardo.move_piece(raw[-2], @cord)
    # puts @boardo.render_board
    anso -= [@cord] unless want_to_check_for_checkmate
    # puts anso.inspect, '249'
    # puts 'Castling inc'
    castling = real_castling(raw_castling)
    # puts castling.inspect, 'castling asfasf'
    # puts 'kokoko'
    anso += castling if castling != []
    anso
  end

  def real_castling(moves)
    anso = [] # Initialize anso array to store valid castling moves
    # puts moves
    moves.each do |move|
      passes = 0
      # puts move.inspect, 'move', @cord.inspect, 'cord'
      in_betweens = [move, [move[0], (move[1] + @cord[1]) / 2]] # Intermediate squares
      # puts in_betweens.inspect, 'inbetween'
      in_betweens.each do |in_between|
        new_board = Marshal.load(Marshal.dump(@boardo)) # Deep copy of board
        new_grid = new_board.instance_variable_get(:@board)
        # puts 'heehee', @cord.inspect, in_between.inspect, 'castling', 'hello!'
        if in_between[1] > @cord[1] # King side castling
          new_board.move_piece([@cord[0], 7], [move[0], 5]) # Move rook
        else # Queen side castling
          new_board.move_piece([@cord[0], 0], [move[0], 3]) # Move rook
        end
        new_board.move_piece(@cord, in_between) # Simulate move
        # Check if any opponent piece attacks the in_between position
        flag = 0
        new_grid.flatten.each do |piecee|
          next if piecee.color == @piece.color || piecee.is_a?(Nullpiece)

          if MoveChecker.new(new_board, piecee).raw_possible_moves.include?(in_between)
            flag = 1
            break
          end
        end
        passes += 1 if flag == 0 # Only add if not attacked
      end
      anso << move if passes == 2
    end
    anso
  end

  # below check if nothign is in between!
  def raw_castling
    anso = []
    # puts @piece.castling_privilege
    puts check, 'castling303'
    return anso if check
    return anso unless @piece.castling_privilege

    possible_rooks = [[0, 0], [0, 7], [7, 7], [7, 0]] # Fixed bracket issue
    possible_rooks.each do |possible_rook|
      target_rook_piece = @grid[possible_rook[0]][possible_rook[1]]
      next unless target_rook_piece.is_a?(Rook)

      cond2 = target_rook_piece.castling_privilege
      cond3 = MoveChecker.new(@boardo,
                              target_rook_piece).raw_possible_moves.include?([@piece.position[0],
                                                                              @piece.position[1] + 1])
      cond4 = MoveChecker.new(@boardo,
                              target_rook_piece).raw_possible_moves.include?([@piece.position[0],
                                                                              @piece.position[1] - 1])
      # puts cond3, 'castling307'

      next unless cond2 && (cond3 || cond4)

      anso << [@piece.position[0], (@piece.position[1] + possible_rook[1] + 1) / 2]
    end
    puts anso.inspect, 'castling325'
    anso
    # real_castling(anso)
  end

  # assuming pawn is not promoted yet
  # ADD PROMOTION LATER
  def pawn_moves(cords)
    possible_moves = []
    if @piece.color == 'W'
      if cords[1] > 0 && cords[1] < 7
        # puts @grid[cords[0] - 1][cords[1] - 1]

        possible_moves << [cords[0] - 1, cords[1] - 1] if @grid[cords[0] - 1][cords[1] - 1].color == 'B'
        possible_moves << [cords[0] - 1, cords[1] + 1] if @grid[cords[0] - 1][cords[1] + 1].color == 'B'
        # puts 'tralala213', possible_moves.inspect
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
        possible_moves << [cords[0] - 1, cords[1]] if @grid[cords[0] - 1][cords[1]].is_a?(Nullpiece)
      end
    # puts
    elsif @piece.color == 'B'
      if cords[1] > 0 && cords[1] < 7
        # puts @grid[cords[0] - 1][cords[1] - 1]
        possible_moves << [cords[0] + 1, cords[1] - 1] if @grid[cords[0] + 1][cords[1] - 1].color == 'W'
        possible_moves << [cords[0] + 1, cords[1] + 1] if @grid[cords[0] + 1][cords[1] + 1].color == 'W'
      elsif cords[1] == 7
        possible_moves << [cords[0] + 1, cords[1] - 1] if @grid[cords[0] + 1][cords[1] - 1].color == 'W'
      elsif cords[1] == 0
        possible_moves << [cords[0] + 1, cords[1] + 1] if @grid[cords[0] + 1][cords[1] - 1].color == 'W'
      end
      if cords[0] == 1
        possible_moves << [cords[0] + 1, cords[1]] if @grid[cords[0] + 1][cords[1]].is_a?(Nullpiece)
        if @grid[cords[0] + 1][cords[1]].is_a?(Nullpiece) && @grid[cords[0] + 2][cords[1]].is_a?(Nullpiece)
          possible_moves << [cords[0] + 2, cords[1]]
        end
      elsif cords[0] > 0
        possible_moves << [cords[0] + 1, cords[1]] if @grid[cords[0] + 1][cords[1]].is_a?(Nullpiece)
      end
    end
    # puts possible_moves.inspect, '273'
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
    # puts possible_moves.inspect, '378'
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
puts 'castling'
board = Board.new
ok = board.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[1][4])
# puts checker.real_possible_moves.inspect
# puts checker.pinned
board.move_piece([7, 5], [5, 5])
board.move_piece([7, 6], [5, 6])
board.move_piece([7, 1], [5, 1])
board.move_piece([7, 2], [5, 2])

board.move_piece([7, 3], [5, 3])
board.move_piece([0, 1], [6, 3])
board.render_board
checker2 = MoveChecker.new(board, ok[7][4])
# puts ok[0][0].class
puts checker2.real_possible_moves('W').inspect
# board.render_board
puts '====================='

# puts '====================='
# puts 'BUG'
# board = Board.new
# ok = board.instance_variable_get(:@board)
# # checker = MoveChecker.new(boardo, ok[1][4])
# # puts checker.real_possible_moves.inspect
# # puts checker.pinned
# board.move_piece([6, 3], [1, 4])
# board.move_piece([7, 4], [5, 4])
# board.move_piece([6, 4], [4, 4])
# board.move_piece([1, 4], [3, 4])
# board.move_piece([0, 3], [3, 4])
# board.move_piece([1, 3], [3, 3])
# board.move_piece([1, 2], [4, 5])
# board.move_piece([6, 7], [5, 6])
# board.move_piece([6, 2], [4, 2])
# board.render_board
# checker2 = MoveChecker.new(board, ok[5][4])
# # puts ok[0][0].class
# puts checker2.real_possible_moves('W').inspect
# board.render_board
# puts '====================='

# puts '====================='
# puts 'Final'
# boardo = Board.new
# ok = boardo.instance_variable_get(:@board)
# checker = MoveChecker.new(boardo, ok[7][4])
# # puts checker.real_possible_moves
# # puts checker.pinned
# boardo.move_piece([7, 4], [5, 4])
# # boardo.move_piece([0, 2], [2, 1])
# boardo.move_piece([7, 3], [3, 4])
# # boardo.move_piece([0, 5], [2, 7])
# boardo.move_piece([0, 3], [2, 4])
# # boardo.move_piece([0, 6], [3, 5])
# # boardo.move_piece([1, 6], [4, 3])
# boardo.render_board
# checker2 = MoveChecker.new(boardo, ok[1][5])
# puts checker2.real_possible_moves.inspect
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
