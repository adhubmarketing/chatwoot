# == Schema Information
#
# Table name: kanban_board_agents
#
#  id         :bigint           not null, primary key
#  account_id :bigint           not null
#  board_id   :bigint           not null
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_kanban_board_agents_on_account_id        (account_id)
#  index_kanban_board_agents_on_board_id          (board_id)
#  index_kanban_board_agents_on_board_id_and_user_id (board_id, user_id) UNIQUE
#  index_kanban_board_agents_on_user_id           (user_id)
#
class Kanban::BoardAgent < ApplicationRecord
  self.table_name = 'kanban_board_agents'

  belongs_to :account
  belongs_to :board, class_name: 'Kanban::Board'
  belongs_to :user

  validates :user_id, uniqueness: { scope: :board_id }
end
