# == Schema Information
#
# Table name: kanban_board_steps
#
#  id          :bigint           not null, primary key
#  account_id  :bigint           not null
#  board_id    :bigint           not null
#  name        :string           not null
#  description :text
#  color       :string           not null, default: '#1f93ff'
#  tasks_count :integer          default(0), not null
#  cancelled   :boolean          default(false), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_kanban_board_steps_on_account_id       (account_id)
#  index_kanban_board_steps_on_board_id         (board_id)
#  index_kanban_board_steps_on_board_id_and_name (board_id, name) UNIQUE
#
class Kanban::BoardStep < ApplicationRecord
  belongs_to :account
  belongs_to :board, class_name: 'Kanban::Board'
  has_many :tasks, class_name: 'Kanban::Task', foreign_key: :step_id, dependent: :nullify

  validates :name,
            presence: { message: I18n.t('errors.validations.presence') },
            uniqueness: { scope: :board_id }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: 'must be a valid hex color (e.g., #1f93ff)' }

  after_create :add_to_board_steps_order
  after_destroy :remove_from_board_steps_order

  private

  def add_to_board_steps_order
    board.steps_order << id unless board.steps_order.include?(id)
    board.save
  end

  def remove_from_board_steps_order
    board.steps_order.delete(id)
    board.save
  end
end
