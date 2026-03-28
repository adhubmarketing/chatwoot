# == Schema Information
#
# Table name: kanban_audit_events
#
#  id              :bigint           not null, primary key
#  account_id      :bigint           not null
#  task_id         :bigint           not null
#  action          :string           not null
#  metadata        :jsonb            default({})
#  performed_by_id :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_kanban_audit_events_on_account_id           (account_id, created_at)
#  index_kanban_audit_events_on_task_id              (task_id, created_at)
#  index_kanban_audit_events_on_performed_by_id      (performed_by_id)
#
class Kanban::AuditEvent < ApplicationRecord
  belongs_to :account
  belongs_to :task, class_name: 'Kanban::Task'
  belongs_to :performed_by, class_name: 'User'

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for_task, ->(task_id) { where(task_id: task_id) }
end
