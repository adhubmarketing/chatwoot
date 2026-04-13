require 'rails_helper'

RSpec.describe Kanban::Task do
  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:board).class_name('Kanban::Board') }
    it { is_expected.to belong_to(:step).class_name('Kanban::BoardStep').optional }
    it { is_expected.to have_many(:task_agents).class_name('Kanban::TaskAgent') }
    it { is_expected.to have_many(:assigned_agents).through(:task_agents) }
    it { is_expected.to have_many(:task_contacts).class_name('Kanban::TaskContact') }
    it { is_expected.to have_many(:contacts).through(:task_contacts) }
    it { is_expected.to have_many(:audit_events).class_name('Kanban::AuditEvent') }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:description).is_at_most(5000) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:priority).with_values(low: 0, medium: 1, high: 2, urgent: 3) }
  end

  describe 'scopes' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:step) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }

    describe '.overdue' do
      let!(:overdue_task) do
        FactoryBot.create(:kanban_task, board: board, step: step, account: board.account, due_date: 2.days.ago)
      end
      let!(:upcoming_task) do
        FactoryBot.create(:kanban_task, board: board, step: step, account: board.account, due_date: 2.days.from_now)
      end
      let!(:no_due_date_task) do
        FactoryBot.create(:kanban_task, board: board, step: step, account: board.account, due_date: nil)
      end

      it 'returns only overdue tasks' do
        expect(described_class.overdue).to include(overdue_task)
        expect(described_class.overdue).not_to include(upcoming_task)
        expect(described_class.overdue).not_to include(no_due_date_task)
      end
    end
  end

  describe '#move_to_step' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:step1) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }
    let(:step2) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }
    let(:task) { FactoryBot.create(:kanban_task, board: board, step: step1, account: board.account, position: 0) }

    it 'moves task to new step' do
      task.move_to_step(step2.id)
      expect(task.reload.step_id).to eq(step2.id)
    end

    it 'updates step_changed_at timestamp' do
      travel_to 1.hour.from_now do
        expect { task.move_to_step(step2.id) }.to change { task.reload.step_changed_at }.from(nil)
      end
    end
  end

  describe '#add_agents' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:step) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }
    let(:task) { FactoryBot.create(:kanban_task, board: board, step: step, account: board.account) }
    let(:users) { FactoryBot.create_list(:user, 3, account: board.account) }

    it 'adds agents to task' do
      task.add_agents(users.map(&:id))
      expect(task.reload.assigned_agents.size).to eq(3)
    end

    it 'does not duplicate agents' do
      task.add_agents([users.first.id])
      task.add_agents([users.first.id])
      expect(task.reload.assigned_agents.size).to eq(1)
    end
  end

  describe '#add_contacts' do
    let(:board) { FactoryBot.create(:kanban_board) }
    let(:step) { FactoryBot.create(:kanban_board_step, board: board, account: board.account) }
    let(:task) { FactoryBot.create(:kanban_task, board: board, step: step, account: board.account) }
    let(:contacts) { FactoryBot.create_list(:contact, 2, account: board.account) }

    it 'adds contacts to task' do
      task.add_contacts(contacts.map(&:id))
      expect(task.reload.contacts.size).to eq(2)
    end

    it 'does not duplicate contacts' do
      task.add_contacts([contacts.first.id])
      task.add_contacts([contacts.first.id])
      expect(task.reload.contacts.size).to eq(1)
    end
  end

  # TODO: Audit events and labels - implement proper test setup
  # describe 'audit events' do
  #   - Audit events require Current.user setup
  # end
  #
  # describe 'labels' do
  #   - Labels require acts_as_taggable tables and proper test setup
  # end
end
