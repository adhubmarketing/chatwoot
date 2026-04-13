# == Schema Information
#
# Table name: kanban_audit_events
#
#  id              :bigint           not null, primary key
#  action          :string           not null
#  metadata        :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  account_id      :bigint           not null
#  performed_by_id :bigint           not null
#  task_id         :bigint           not null
#
# Indexes
#
#  index_kanban_audit_events_on_account_id                 (account_id)
#  index_kanban_audit_events_on_account_id_and_created_at  (account_id,created_at)
#  index_kanban_audit_events_on_performed_by_id            (performed_by_id)
#  index_kanban_audit_events_on_task_id                    (task_id)
#  index_kanban_audit_events_on_task_id_and_created_at     (task_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (performed_by_id => users.id)
#  fk_rails_...  (task_id => kanban_tasks.id)
#
class Kanban::AuditEvent < ApplicationRecord
  self.table_name = 'kanban_audit_events'

  belongs_to :account
  belongs_to :task, class_name: 'Kanban::Task'
  belongs_to :performed_by, class_name: 'User', optional: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_task, ->(task_id) { where(task_id: task_id) }
end
