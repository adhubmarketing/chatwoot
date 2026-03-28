# == Schema Information
#
# Table name: kanban_boards
#
#  id          :bigint           not null, primary key
#  account_id  :bigint           not null
#  name        :string           not null
#  description :text
#  settings    :jsonb            default({})
#  steps_order :integer          array, default([])
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_kanban_boards_on_account_id           (account_id)
#  index_kanban_boards_on_account_id_and_name  (account_id, name) UNIQUE
#
class Kanban::Board < ApplicationRecord
  include AccountCacheRevalidator

  belongs_to :account
  has_many :steps, class_name: 'Kanban::BoardStep', foreign_key: :board_id, dependent: :destroy_async
  has_many :tasks, class_name: 'Kanban::Task', foreign_key: :board_id, dependent: :destroy_async
  has_many :board_agents, class_name: 'Kanban::BoardAgent', foreign_key: :board_id, dependent: :destroy_async
  has_many :assigned_agents, through: :board_agents, source: :user
  has_many :board_inboxes, class_name: 'Kanban::BoardInbox', foreign_key: :board_id, dependent: :destroy_async
  has_many :assigned_inboxes, through: :board_inboxes, source: :inbox

  validates :name,
            presence: { message: I18n.t('errors.validations.presence') },
            uniqueness: { scope: :account_id }

  before_validation do
    self.name = name.strip if attribute_present?('name')
  end

  # Default settings structure
  # {
  #   sync_task_and_conversation_agents: false,
  #   auto_assign_task_to_agent: false,
  #   auto_create_task_for_conversation: false,
  #   auto_resolve_conversation_on_task_end: false,
  #   auto_complete_task_on_conversation_resolve: false
  # }

  # Adds multiple agents to the board
  # @param agent_ids [Array<Integer>] Array of user IDs to add as agents
  # @return [Array<User>] Array of newly added agents
  def add_agents(agent_ids)
    agents_to_create = agent_ids.map { |agent_id| { user_id: agent_id, account_id: account_id } }
    created_agents = board_agents.create(agents_to_create)
    added_users = created_agents.filter_map(&:user)

    update_account_cache
    added_users
  end

  # Removes multiple agents from the board
  # @param agent_ids [Array<Integer>] Array of user IDs to remove
  # @return [void]
  def remove_agents(agent_ids)
    board_agents.where(user_id: agent_ids).destroy_all
    update_account_cache
  end

  # Adds multiple inboxes to the board
  # @param inbox_ids [Array<Integer>] Array of inbox IDs to add
  # @return [Array<Inbox>] Array of newly added inboxes
  def add_inboxes(inbox_ids)
    inboxes_to_create = inbox_ids.map { |inbox_id| { inbox_id: inbox_id, account_id: account_id } }
    created_inboxes = board_inboxes.create(inboxes_to_create)
    added_inboxes = created_inboxes.filter_map(&:inbox)

    update_account_cache
    added_inboxes
  end

  # Removes multiple inboxes from the board
  # @param inbox_ids [Array<Integer>] Array of inbox IDs to remove
  # @return [void]
  def remove_inboxes(inbox_ids)
    board_inboxes.where(inbox_id: inbox_ids).destroy_all
    update_account_cache
  end

  # Reorders the steps on the board
  # @param order_array [Array<Integer>] Array of step IDs in the desired order
  # @return [void]
  def reorder_steps(order_array)
    update(steps_order: order_array)
  end

  def push_event_data
    {
      id: id,
      name: name
    }
  end
end

Kanban::Board.include_mod_with('Audit::Kanban::Board')
