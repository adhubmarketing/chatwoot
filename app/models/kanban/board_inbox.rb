# == Schema Information
#
# Table name: kanban_board_inboxes
#
#  id         :bigint           not null, primary key
#  account_id :bigint           not null
#  board_id   :bigint           not null
#  inbox_id   :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_kanban_board_inboxes_on_account_id         (account_id)
#  index_kanban_board_inboxes_on_board_id           (board_id)
#  index_kanban_board_inboxes_on_board_id_and_inbox_id (board_id, inbox_id) UNIQUE
#  index_kanban_board_inboxes_on_inbox_id           (inbox_id)
#
class Kanban::BoardInbox < ApplicationRecord
  belongs_to :account
  belongs_to :board, class_name: 'Kanban::Board'
  belongs_to :inbox

  validates :inbox_id, uniqueness: { scope: :board_id }
end
