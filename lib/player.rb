class Player
  def initialize(name, color)
    @name = name
    @color = color
  end

  attr_reader :color, :name

  def ask_base
    puts "#{@name}, enter your move (e.g., 'e2 e4'):"
    move = gets.chomp
    # puts move[0]
    # []
    [8 - move[1].to_i, move[0].ord - 'a'.ord]
  end

  def ask_target
    move = gets.chomp
    [8 - move[1].to_i, move[0].ord - 'a'.ord]
  end
end

# player = Player.new('Alice', 'W')
# puts player.ask_target.inspect
