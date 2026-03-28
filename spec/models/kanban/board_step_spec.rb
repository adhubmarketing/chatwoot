require 'rails_helper'

RSpec.describe Kanban::BoardStep do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:board).class_name('Kanban::Board') }
    it { is_expected.to have_many(:tasks).class_name('Kanban::Task') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates uniqueness of name scoped to board' do
      step = FactoryBot.create(:kanban_board_step)
      expect(step).to validate_uniqueness_of(:name).scoped_to(:board_id)
    end

    it 'validates color format' do
      step = FactoryBot.build(:kanban_board_step, color: 'invalid')
      expect(step).not_to be_valid
      expect(step.errors[:color]).to include('must be a valid hex color (e.g., #1f93ff)')
    end

    it 'accepts valid hex colors' do
      step = FactoryBot.build(:kanban_board_step, color: '#1f93ff')
      expect(step).to be_valid
    end
  end

  describe 'callbacks' do
    let(:board) { FactoryBot.create(:kanban_board) }

    describe 'after_create' do
      it 'adds step id to board steps_order' do
        step = FactoryBot.create(:kanban_board_step, board: board, account: board.account)
        expect(board.reload.steps_order).to include(step.id)
      end
    end

    describe 'after_destroy' do
      it 'removes step id from board steps_order' do
        step = FactoryBot.create(:kanban_board_step, board: board, account: board.account)
        expect(board.reload.steps_order).to include(step.id)

        step.destroy
        expect(board.reload.steps_order).not_to include(step.id)
      end
    end
  end
end
