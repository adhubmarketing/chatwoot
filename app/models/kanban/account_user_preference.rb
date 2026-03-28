# == Schema Information
#
# Table name: kanban_account_user_preferences
#
#  id          :bigint           not null, primary key
#  account_id  :bigint           not null
#  user_id     :bigint           not null
#  preferences :jsonb            default({})
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_kanban_prefs_on_account_and_user (account_id, user_id) UNIQUE
#
class Kanban::AccountUserPreference < ApplicationRecord
  self.table_name = 'kanban_account_user_preferences'

  belongs_to :account
  belongs_to :user

  validates :user_id, uniqueness: { scope: :account_id }

  # Preferences structure:
  # {
  #   favorite_board_ids: [1, 2, 3],
  #   board_sort_preferences: {
  #     board_id_1: { sort_by: 'priority', direction: 'desc' },
  #     board_id_2: { sort_by: 'due_date', direction: 'asc' }
  #   }
  # }

  # Toggles a board as favorite
  # @param board_id [Integer] The board ID to toggle
  # @return [Boolean] True if now favorited, false if unfavorited
  def toggle_favorite(board_id)
    current_favorites = (preferences['favorite_board_ids'] || [])

    if current_favorites.include?(board_id)
      current_favorites.delete(board_id)
      favorited = false
    else
      current_favorites << board_id
      favorited = true
    end

    update(preferences: preferences.merge('favorite_board_ids' => current_favorites))
    favorited
  end

  # Updates sort preference for a specific board
  # @param board_id [Integer] The board ID
  # @param sort_by [String] The field to sort by
  # @param direction [String] Sort direction ('asc' or 'desc')
  # @return [Boolean] Success status
  def update_sort_preference(board_id, sort_by:, direction: 'asc')
    sort_prefs = preferences['board_sort_preferences'] || {}
    sort_prefs[board_id.to_s] = { 'sort_by' => sort_by, 'direction' => direction }

    update(preferences: preferences.merge('board_sort_preferences' => sort_prefs))
  end

  # Gets favorite board IDs
  # @return [Array<Integer>] Array of board IDs
  def favorite_board_ids
    preferences['favorite_board_ids'] || []
  end

  # Gets sort preference for a board
  # @param board_id [Integer] The board ID
  # @return [Hash] Sort preferences
  def sort_preference_for_board(board_id)
    sort_prefs = preferences['board_sort_preferences'] || {}
    sort_prefs[board_id.to_s] || { 'sort_by' => 'position', 'direction' => 'asc' }
  end
end
