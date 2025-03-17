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

  def generate_children(color)
    original_board = @board.deep_dup
    # original_board.render_board
    original_board.board.flatten.each do |square| # this is the grid
      next if square.is_a?(Nullpiece)
      next if square.color != color

      move_checker = MoveChecker.new(@board, square)
      single_piece_moves = move_checker.real_possible_moves(color)
      single_piece_moves.each do |move|
        new_board = @board.deep_dup
        # captured_piece = @board.board[move[0]][move[1]]
        # puts square.position.inspect
        # puts move.inspect
        # puts captured_piece.class
        new_board.move_piece(square.position, move)
        # new_board.render_board

        new_node = Node.new(new_board, move, self)
        @children << new_node
        # puts([square.position, move, captured_piece]).inspect
        # @board.board = @board.revive_board_config([square.position, move, captured_piece])
        # @board.render_board
      end
    end
    # puts @children.inspect
  end
end

# # Example usage:
# board = Board.new
# root = Node.new(board)
# root.generate_children('W')
# puts root.children
