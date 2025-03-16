class Player
  def initialize(name, color)
    @name = name
    @color = color
  end

  attr_reader :color, :name

  def ask_base
    puts "#{@name}, enter your move (e.g., 'e2 e4'):"
    puts "Press 's' to save and quit, 'q' to simply quit, 'l' to load , 'u' to undo"
    move = gets.chomp
    return move if %w[s q l u].include?(move)

    # puts move[0]
    # []
    [8 - move[1].to_i, move[0].ord - 'a'.ord]
  end

  def ask_target
    puts 're to select another piece'
    puts "Press 's' to save and quit, 'q' to simply quit, 'l' to load , 'u' to undo"
    move = gets.chomp
    return move if %w[s q l u re].include?(move)

    [8 - move[1].to_i, move[0].ord - 'a'.ord]
  end
end

# player = Player.new('Alice', 'W')
# puts player.ask_target.inspect
