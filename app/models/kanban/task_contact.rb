# == Schema Information
#
# Table name: kanban_task_contacts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint           not null
#  contact_id :bigint           not null
#  task_id    :bigint           not null
#
# Indexes
#
#  index_kanban_task_contacts_on_account_id              (account_id)
#  index_kanban_task_contacts_on_contact_id              (contact_id)
#  index_kanban_task_contacts_on_task_id                 (task_id)
#  index_kanban_task_contacts_on_task_id_and_contact_id  (task_id,contact_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (contact_id => contacts.id)
#  fk_rails_...  (task_id => kanban_tasks.id)
#
class Kanban::TaskContact < ApplicationRecord
  self.table_name = 'kanban_task_contacts'

  belongs_to :account
  belongs_to :task, class_name: 'Kanban::Task'
  belongs_to :contact

  validates :contact_id, uniqueness: { scope: :task_id }
end
