puts "Memory before: #{`ps -o rss= -p #{Process.pid}`.to_i} KB"
require_relative 'node'
require_relative 'board'
class ChessEngine
  def initialize(board, color)
    @board = board
    @color = color
  end

  def treeize(depth, root, color)
    return if depth == 0

    root.generate_children(color)
    root.children.each do |child|
      new_color = color == 'W' ? 'B' : 'W'
      treeize(depth - 1, child, new_color) if depth > 0
    end
  end
end
start_time = Time.now

board = Board.new

board.move_piece([7, 5], [5, 5])
board.move_piece([7, 6], [5, 6])
board.move_piece([7, 1], [5, 1])
board.move_piece([7, 2], [5, 2])

board.move_piece([7, 3], [5, 3])
board.move_piece([0, 1], [6, 3])
engine = ChessEngine.new(board, 'W')
root = Node.new(board)
# root.generate_children('W')
engine.treeize(3, root, 'W')
# puts root.children[0].children
end_time = Time.now
# puts root.children

puts "Execution time: #{end_time - start_time} seconds"
# puts "Memory used: #{ObjectSpace.memsize_of_all / 1024.0} KB"
# memory_kb = `ps -o rss= -p #{Process.pid}`.strip.to_i
puts "Memory after: #{`ps -o rss= -p #{Process.pid}`.to_i} KB"
