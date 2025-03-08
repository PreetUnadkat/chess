require 'rspec'
require_relative '../lib/board'
require_relative '../lib/pieces/knight'
require_relative '../lib/pieces/bishop'
require_relative '../lib/pieces/rook'
require_relative '../lib/pieces/queen'
require_relative '../lib/pieces/king'
require_relative '../lib/pieces/pawn'

RSpec.describe Board do
  let(:board) { Board.new }

  describe '#initialize' do
    it 'creates an 8x8 board' do
      expect(board.instance_variable_get(:@board).size).to eq(8)
      expect(board.instance_variable_get(:@board).all? { |row| row.size == 8 }).to be true
    end
  end

  describe '#populate_board' do
    it 'places pieces correctly' do
      board_data = board.instance_variable_get(:@board)

      # Check major pieces
      expect(board_data[0][0]).to be_a(Rook)
      expect(board_data[0][7]).to be_a(Rook)
      expect(board_data[7][0]).to be_a(Rook)
      expect(board_data[7][7]).to be_a(Rook)

      expect(board_data[0][1]).to be_a(Knight)
      expect(board_data[0][6]).to be_a(Knight)
      expect(board_data[7][1]).to be_a(Knight)
      expect(board_data[7][6]).to be_a(Knight)

      expect(board_data[0][2]).to be_a(Bishop)
      expect(board_data[0][5]).to be_a(Bishop)
      expect(board_data[7][2]).to be_a(Bishop)
      expect(board_data[7][5]).to be_a(Bishop)

      expect(board_data[0][3]).to be_a(Queen)
      expect(board_data[7][3]).to be_a(Queen)

      expect(board_data[0][4]).to be_a(King)
      expect(board_data[7][4]).to be_a(King)

      # Check pawns
      (0..7).each do |i|
        expect(board_data[1][i]).to be_a(Pawn)
        expect(board_data[6][i]).to be_a(Pawn)
      end
    end
  end

  describe '#print' do
    it 'prints without errors' do
      expect { board.print }.not_to raise_error
    end
  end
end
