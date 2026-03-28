# == Schema Information
#
# Table name: kanban_tasks
#
#  id               :bigint           not null, primary key
#  account_id       :bigint           not null
#  board_id         :bigint           not null
#  step_id          :bigint
#  title            :string           not null
#  description      :text             (max 5000 characters)
#  priority         :integer          default(0), not null
#  position         :integer          not null
#  start_date       :date
#  due_date         :date
#  cached_label_list :string
#  step_changed_at  :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_kanban_tasks_on_account_id                (account_id)
#  index_kanban_tasks_on_board_id_step_id_position (board_id, step_id, position)
#  index_kanban_tasks_on_due_date                  (due_date)
#  index_kanban_tasks_on_priority                  (priority)
#
class Kanban::Task < ApplicationRecord
  self.table_name = 'kanban_tasks'

  include Labelable

  belongs_to :account
  belongs_to :board, class_name: 'Kanban::Board', counter_cache: false
  belongs_to :step, class_name: 'Kanban::BoardStep', optional: true, counter_cache: :tasks_count

  has_many :task_agents, class_name: 'Kanban::TaskAgent', foreign_key: :task_id, dependent: :destroy_async
  has_many :assigned_agents, through: :task_agents, source: :user

  has_many :task_contacts, class_name: 'Kanban::TaskContact', foreign_key: :task_id, dependent: :destroy_async
  has_many :contacts, through: :task_contacts

  has_many :conversations, class_name: 'Conversation', foreign_key: :kanban_task_id, dependent: :nullify

  has_many :audit_events, class_name: 'Kanban::AuditEvent', foreign_key: :task_id, dependent: :destroy_async

  enum priority: { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :title, presence: true
  validates :description, length: { maximum: 5000 }

  scope :overdue, -> { where('due_date < ?', Date.today) }
  scope :by_priority, -> { order(priority: :desc) }
  scope :by_position, -> { order(position: :asc) }

  before_create :set_default_position
  before_update :track_step_change
  after_commit :create_audit_event, on: [:create, :update]

  # Moves task to a new step with optional positioning
  # @param new_step_id [Integer] The target step ID
  # @param insert_before_task_id [Integer, nil] Optional task ID to insert before
  # @return [Boolean] Success status
  def move_to_step(new_step_id, insert_before_task_id: nil)
    transaction do
      old_step_id = step_id
      update(step_id: new_step_id, step_changed_at: Time.current)

      # Update counter caches
      Kanban::BoardStep.reset_counters(old_step_id, :tasks) if old_step_id
      Kanban::BoardStep.reset_counters(new_step_id, :tasks) if new_step_id

      true
    end
  end

  # Adds multiple agents to the task
  # @param agent_ids [Array<Integer>] Array of user IDs to add as agents
  # @return [Array<User>] Array of newly added agents
  def add_agents(agent_ids)
    agents_to_create = agent_ids.map { |agent_id| { user_id: agent_id, account_id: account_id } }
    created_agents = task_agents.create(agents_to_create)
    created_agents.filter_map(&:user)
  end

  # Removes multiple agents from the task
  # @param agent_ids [Array<Integer>] Array of user IDs to remove
  # @return [void]
  def remove_agents(agent_ids)
    task_agents.where(user_id: agent_ids).destroy_all
  end

  # Adds multiple contacts to the task
  # @param contact_ids [Array<Integer>] Array of contact IDs to add
  # @return [Array<Contact>] Array of newly added contacts
  def add_contacts(contact_ids)
    contacts_to_create = contact_ids.map { |contact_id| { contact_id: contact_id, account_id: account_id } }
    created_contacts = task_contacts.create(contacts_to_create)
    created_contacts.filter_map(&:contact)
  end

  # Removes multiple contacts from the task
  # @param contact_ids [Array<Integer>] Array of contact IDs to remove
  # @return [void]
  def remove_contacts(contact_ids)
    task_contacts.where(contact_id: contact_ids).destroy_all
  end

  private

  def set_default_position
    return if position.present?

    max_position = board.tasks.where(step_id: step_id).maximum(:position) || -1
    self.position = max_position + 1
  end

  def track_step_change
    if step_id_changed? && !step_changed_at_changed?
      self.step_changed_at = Time.current
    end
  end

  def create_audit_event
    changes_to_save = previous_changes.presence || saved_changes
    return unless changes_to_save.any?

    action = if changes_to_save.key?('id')
               'created'
             elsif changes_to_save.key?('step_id')
               'moved'
             else
               'updated'
             end

    audit_events.create!(
      account_id: account_id,
      action: action,
      metadata: {
        changes: changes_to_save.except('updated_at'),
        changed_at: Time.current
      },
      performed_by_id: Current.user&.id
    )
  rescue StandardError => e
    Rails.logger.error "Failed to create audit event: #{e.message}"
  end
end
