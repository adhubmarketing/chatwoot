FactoryBot.define do
  factory :kanban_board_step, class: 'Kanban::BoardStep' do
    account
    association :board, factory: :kanban_board
    sequence(:name) { |n| "Step #{n}" }
    description { 'A test step' }
    color { '#1f93ff' }
    tasks_count { 0 }
    cancelled { false }
  end
end
