class Player
  def initialize(name, color)
    @name = name
    @color = color
  end

  def ask_base
    puts "#{@name}, enter your move (e.g., 'e2 e4'):"
    move = gets.chomp
    [move[1].to_i, move[0].ord - 'a'.ord + 1]
  end

  def ask_target(base_cord)
    puts "#{@name}, you want to move from #{(base_cord[0] + 96).char}#{base_cord[1]} to where?:"
    move = gets.chomp
    [move[1].to_i, move[0].ord - 'a'.ord + 1]
  end
end
