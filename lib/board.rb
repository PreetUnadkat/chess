require_relative 'piece'
require_relative 'pieces/knight'
require_relative 'pieces/bishop'
require_relative 'pieces/rook'
require_relative 'pieces/queen'
require_relative 'pieces/king'
require_relative 'pieces/pawn'
require_relative 'pieces/nullpiece'

class Board
  attr_accessor :board

  def initialize(variant = 'standard')
    @board = Array.new(8) { Array.new(8) }
    @variant = variant
    populate_board
  end

  def populate_board
    (0..7).each do |row|
      (0..7).each do |col|
        @board[row][col] = Nullpiece.new(nil, [row, col])
      end
    end
    # Adding only standard right now.
    pieces = {
      rook: [Rook, [[0, 0], [0, 7], [7, 0], [7, 7]]],
      knight: [Knight, [[0, 1], [0, 6], [7, 1], [7, 6]]],
      bishop: [Bishop, [[0, 2], [0, 5], [7, 2], [7, 5]]],
      queen: [Queen, [[0, 3], [7, 3]]],
      king: [King, [[0, 4], [7, 4]]],
      pawn: [Pawn, (0..7).map { |i| [1, i] } + (0..7).map { |i| [6, i] }]
    }
    pieces.each_value do |(klass, positions)|
      positions.each do |pos|
        color = pos[0] < 2 ? 'B' : 'W'
        @board[pos[0]][pos[1]] = klass.new(color, [pos[0], pos[1]])
      end
    end
  end

  def render_board
    puts "\n  a b c d e f g h"
    @board.each_with_index do |row, i|
      print "#{8 - i} " # Row numbers (from 8 to 1)
      row.each do |piece|
        print piece.is_a?(Nullpiece) ? '. ' : "#{piece} "
      end
      puts
    end
  end

  def deep_dup
    new_board = Board.new
    new_board.board = @board.map do |row|
      row.map { |piece| piece.dup } # Ensure each piece is properly duplicated
    end
    new_board
  end

  def rook_move_castle(color, end_pos)
    king = find_king(color)
    i = color == 'W' ? 1 : -1
    if end_pos == [king.position[0], king.position[1] + 2 * i]
      rook_start_pos = [king.position[0], king.position[1] + 3 * i]
      rook_end_pos = [king.position[0], king.position[1] + i]
    elsif end_pos == [king.position[0], king.position[1] - 2 * i]
      rook_start_pos = [king.position[0], king.position[1] - 4 * i]
      rook_end_pos = [king.position[0], king.position[1] - i]
    end
    rook = @board[rook_start_pos[0]][rook_start_pos[1]]
    @board[rook_end_pos[0]][rook_end_pos[1]] = rook
    @board[rook_start_pos[0]][rook_start_pos[1]] = Nullpiece.new(nil, rook_start_pos)
    rook.position = rook_end_pos
  end

  def move_piece(start_pos, end_pos)
    # puts start_pos.inspect, end_pos.inspect
    piece = @board[start_pos[0]][start_pos[1]]
    piece.revoke_castling_privilege if piece.is_a?(King)
    piece.revoke_castling_privilege if piece.is_a?(Rook) && [[0, 0], [7, 0], [0, 7], [7, 7]].include?(start_pos)
    if piece.is_a?(Pawn) && ((piece.color == 'W' && end_pos[0] == 0) or (piece.color == 'B' && end_pos[0] == 7))
      piece = piece.promote
    end
    # render_board if (end_pos[1] - start_pos[1]).abs == 2 && piece.is_a?(King)

    # puts [end_pos, start_pos].inspect if (end_pos[1] - start_pos[1]).abs == 2 && piece.is_a?(King)
    rook_move_castle(piece.color, end_pos) if (end_pos[1] - start_pos[1]).abs == 2 && piece.is_a?(King)
    @board[end_pos[0]][end_pos[1]] = piece
    @board[start_pos[0]][start_pos[1]] = Nullpiece.new(nil, start_pos)
    piece.position = end_pos
  end

  def find_king(color)
    @board.flatten.find { |piece| piece.is_a?(King) && piece.color == color }
    # return [] if king_piece.nil?
    # king_piece.position
  end

  # i admit this is ever so slightly wrong, when rook moves and comes back to original position, and again
  #  moves and then move is undoed it gains castling priveledge! sed i could maybe check thru all logs to see rook moves or i could make double
  #  revoke castling priveledge, or keep previous board changes cache (which wouldnt work for multiple undos!) but i think that would be a bit too much
  #  aka i am lazy!
  def revive_board_config(log)
    starting_piece = @board[log[1][0]][log[1][1]]
    @board[log[1][0]][log[1][1]] = log[2]
    @board[log[1][0]][log[1][1]].position = log[1]
    @board[log[0][0]][log[0][1]] = starting_piece
    @board[log[0][0]][log[0][1]].position = log[0]

    if starting_piece.is_a?(King)
      starting_piece.give_castling_privilege
      if (log[0][1] - log[1][1]).abs == (2)
        i = starting_piece.color == 'W' ? 7 : 0
        if log[0][1] > log[1][1]
          move_piece([i, 3], [i, 0])
          @board[i][0].give_castling_privilege
        else
          move_piece([i, 5], [i, 7])
          @board[i][7].give_castling_privilege
        end
      end
    end
    # puts @board[log[0][0]][log[0][1]]

    starting_piece.give_castling_privilege if starting_piece.is_a?(Rook)
    @board
  end

  def display_possible_moves(moves)
    puts "\n  a b c d e f g h"
    @board.each_with_index do |row, i|
      print "#{8 - i} " # Row numbers (from 8 to 1)
      row.each do |piece|
        if moves.include?(piece.position)
          if piece.is_a?(Nullpiece)
            print "\e[42m.\e[0m " # Green background for empty move
          else
            print "\e[41m#{piece}\e[0m " # Red background for captures
          end
        else
          print piece.is_a?(Nullpiece) ? '. ' : "#{piece} " # Default board display
        end
      end
      puts
    end
  end
end

# board = Board.new
# board.render_board
# new = board.deep_dup
# board.move_piece([1, 0], [0, 0])
# new.render_board
# board.render_board
# print board.instance_variable_get(:@board)[0][0]
