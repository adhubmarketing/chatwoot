# == Schema Information
#
# Table name: kanban_task_agents
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  task_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_kanban_task_agents_on_account_id           (account_id)
#  index_kanban_task_agents_on_task_id              (task_id)
#  index_kanban_task_agents_on_task_id_and_user_id  (task_id,user_id) UNIQUE
#  index_kanban_task_agents_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (task_id => kanban_tasks.id)
#  fk_rails_...  (user_id => users.id)
#
class Kanban::TaskAgent < ApplicationRecord
  self.table_name = 'kanban_task_agents'

  belongs_to :account
  belongs_to :task, class_name: 'Kanban::Task'
  belongs_to :user

  validates :user_id, uniqueness: { scope: :task_id }
end
