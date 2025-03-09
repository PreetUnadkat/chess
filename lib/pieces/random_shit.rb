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
