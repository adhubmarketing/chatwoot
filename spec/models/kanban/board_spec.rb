require 'rails_helper'

RSpec.describe Kanban::Board do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:steps).class_name('Kanban::BoardStep') }
    it { is_expected.to have_many(:tasks).class_name('Kanban::Task') }
    it { is_expected.to have_many(:board_agents).class_name('Kanban::BoardAgent') }
    it { is_expected.to have_many(:assigned_agents).through(:board_agents) }
    it { is_expected.to have_many(:board_inboxes).class_name('Kanban::BoardInbox') }
    it { is_expected.to have_many(:assigned_inboxes).through(:board_inboxes) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }

    it 'validates uniqueness of name scoped to account' do
      board = FactoryBot.create(:kanban_board)
      expect(board).to validate_uniqueness_of(:name).scoped_to(:account_id)
    end
  end

  describe '#add_agents' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:users) { FactoryBot.create_list(:user, 3, account: board.account) }

    before do
      allow(Rails.configuration.dispatcher).to receive(:dispatch)
    end

    it 'adds all agents and resets cache keys' do
      board.add_agents(users.map(&:id))
      expect(board.reload.assigned_agents.size).to eq(3)

      expect(Rails.configuration.dispatcher).to have_received(:dispatch).at_least(:once)
                                                                        .with(
                                                                          'account.cache_invalidated',
                                                                          kind_of(Time),
                                                                          account: board.account,
                                                                          cache_keys: board.account.cache_keys
                                                                        )
    end
  end

  describe '#remove_agents' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:users) { FactoryBot.create_list(:user, 3, account: board.account) }

    before do
      board.add_agents(users.map(&:id))
      allow(Rails.configuration.dispatcher).to receive(:dispatch)
    end

    it 'removes the agents and resets cache keys' do
      expect(board.reload.assigned_agents.size).to eq(3)

      board.remove_agents(users.map(&:id))
      expect(board.reload.assigned_agents.size).to eq(0)

      expect(Rails.configuration.dispatcher).to have_received(:dispatch).at_least(:once)
    end
  end

  describe '#add_inboxes' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:inboxes) { FactoryBot.create_list(:inbox, 2, account: board.account) }

    it 'adds all inboxes' do
      board.add_inboxes(inboxes.map(&:id))
      expect(board.reload.assigned_inboxes.size).to eq(2)
    end
  end

  describe '#remove_inboxes' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:inboxes) { FactoryBot.create_list(:inbox, 2, account: board.account) }

    before do
      board.add_inboxes(inboxes.map(&:id))
    end

    it 'removes the inboxes' do
      expect(board.reload.assigned_inboxes.size).to eq(2)

      board.remove_inboxes(inboxes.map(&:id))
      expect(board.reload.assigned_inboxes.size).to eq(0)
    end
  end

  describe '#reorder_steps' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let!(:step1) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }
    let!(:step2) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }
    let!(:step3) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }

    it 'updates the steps_order array' do
      new_order = [step3.id, step1.id, step2.id]
      board.reorder_steps(new_order)
      expect(board.reload.steps_order).to eq(new_order)
    end
  end
end
