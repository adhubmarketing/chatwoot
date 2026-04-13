FactoryBot.define do
  factory :kanban_board, class: 'Kanban::Board' do
    account
    sequence(:name) { |n| "Board #{n}" }
    description { 'A test kanban board' }
    settings { {} }
    steps_order { [] }
  end
end
