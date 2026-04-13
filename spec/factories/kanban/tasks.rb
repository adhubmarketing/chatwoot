FactoryBot.define do
  factory :kanban_task, class: 'Kanban::Task' do
    account
    association :board, factory: :kanban_board
    association :step, factory: :kanban_board_step
    sequence(:title) { |n| "Task #{n}" }
    description { 'A test task description' }
    priority { :medium }
    position { 0 }
    start_date { nil }
    due_date { nil }
    cached_label_list { '' }
  end
end
