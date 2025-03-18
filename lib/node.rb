require_relative 'move_checker'
require_relative 'board'

class Node
  attr_accessor :board, :move, :children, :parent

  def initialize(board, move = nil, parent = nil)
    @board = board      # current board
    @children = []      # List of child nodes
    @move = move # Move that generated this node
    @parent = parent # Reference to the parent node
  end

  # Experimental!
  def give_board
    return @board unless @board.nil?

    # @parent.give_board.move_piece(@move[0], @move[1])
    # puts @move
    bo = @parent.give_board
    bo = bo.deep_dup
    bo.move_piece(@move[0], @move[1])
    bo
  end

  def generate_children(color)
    # arro = []
    boardo = give_board
    # boardo.render_board
    # original_board = boardo.deep_dup
    # original_board.render_board
    pieso = Nullpiece.new([0, 0], boardo)
    move_checker = MoveChecker.new(boardo, pieso)
    boardo.board.each do |row|
      row.each do |square|
        next if square.is_a?(Nullpiece)
        next if square.color != color

        # puts square.position, 'dfsdgsd'
        move_checker.piece = square
        starting_pos = square.position
        move_checker.cord = starting_pos
        # pieso = square
        # start_time = Time.now
        # puts 'ok'
        # move_checker = MoveChecker.new(boardo, square)
        # puts move_checker.cord.inspect
        # puts 'jingallaa'
        single_piece_moves = move_checker.real_possible_moves(color)
        # puts single_piece_moves, 'lolssfdsd'
        single_piece_moves.each do |move|
          # new_board = @board.deep_dup
          # captured_piece = @board.board[move[0]][move[1]]
          # puts square.position.inspect
          # puts move.inspect
          # puts captured_piece.class
          # new_board.move_piece(square.position, move)
          # boardo.render_board
          @children << Node.new(nil, [starting_pos, move], self)
          # puts([square.position, move, captured_piece]).inspect
          # @board.board = @board.revive_board_config([square.position, move, captured_piece])
          # @board.render_board
        end
        # end_time = Time.now
        # ti = end_time - start_time
        # arro << ti
        # puts "Execution time: #{ti} seconds, Piece: #{square.class}"
      end
    end
    # boardo.board.flatten.each do |square| # this is the grid
    # end
    # GC.start
    # puts @children.inspect
    # puts arro.sum
  end
end

# board = Board.new
# root = Node.new(board)
# root.generate_children('W')
# root.children[0].give_board.render_board
