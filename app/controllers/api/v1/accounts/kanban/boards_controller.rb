class Api::V1::Accounts::Kanban::BoardsController < Api::V1::Accounts::BaseController
  before_action :fetch_board, only: [:show, :update, :destroy, :toggle_favorite, :update_agents, :update_inboxes, :conversations]
  before_action :check_authorization
  before_action :fetch_or_create_user_preferences, only: [:index, :toggle_favorite]

  def index
    @boards = Current.account.kanban_boards.includes(:steps, :assigned_agents, :assigned_inboxes)
    @preferences = @user_preferences
  end

  def show; end

  def create
    @board = Current.account.kanban_boards.new(board_params)
    @board.save!
  end

  def update
    @board.update!(board_params)
  end

  def destroy
    @board.destroy!
    head :ok
  end

  def toggle_favorite
    favorited = @user_preferences.toggle_favorite(@board.id)
    render json: { favorited: favorited }
  end

  def update_agents
    agent_ids = params[:agent_ids] || []
    current_agent_ids = @board.assigned_agents.pluck(:id)

    # Remove agents not in the new list
    to_remove = current_agent_ids - agent_ids
    @board.remove_agents(to_remove) if to_remove.any?

    # Add new agents
    to_add = agent_ids - current_agent_ids
    @board.add_agents(to_add) if to_add.any?

    @board.reload
    render :show
  end

  def update_inboxes
    inbox_ids = params[:inbox_ids] || []
    current_inbox_ids = @board.assigned_inboxes.pluck(:id)

    # Remove inboxes not in the new list
    to_remove = current_inbox_ids - inbox_ids
    @board.remove_inboxes(to_remove) if to_remove.any?

    # Add new inboxes
    to_add = inbox_ids - current_inbox_ids
    @board.add_inboxes(to_add) if to_add.any?

    @board.reload
    render :show
  end

  def conversations
    inbox_ids = @board.assigned_inboxes.pluck(:id)
    @conversations = Current.account.conversations
                                    .where(inbox_id: inbox_ids)
                                    .includes(:assignee, :contact, :kanban_task)
                                    .page(params[:page])
                                    .per(25)

    # Apply optional filters
    @conversations = @conversations.where(status: params[:status]) if params[:status].present?
    @conversations = @conversations.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
  end

  private

  def fetch_board
    @board = Current.account.kanban_boards.find(params[:id])
  end

  def fetch_or_create_user_preferences
    @user_preferences = Kanban::AccountUserPreference.find_or_create_by(
      account_id: Current.account.id,
      user_id: Current.user.id
    )
  end

  def board_params
    params.require(:board).permit(:name, :description, settings: {})
  end

  def check_authorization
    authorize(@board || Kanban::Board)
  end
end
