class Api::V1::Accounts::Kanban::StepsController < Api::V1::Accounts::BaseController
  before_action :fetch_step, only: [:show, :update, :destroy]
  before_action :check_authorization

  def index
    steps = Current.account.kanban_board_steps.includes(:tasks)

    # Apply optional filters
    if params[:board_id].present?
      steps = steps.where(board_id: params[:board_id])
    end

    if params[:agent_id].present?
      # Filter steps that have tasks assigned to this agent
      task_step_ids = Kanban::Task.joins(:task_agents)
                                   .where(kanban_task_agents: { user_id: params[:agent_id] })
                                   .distinct
                                   .pluck(:step_id)
                                   .compact
      steps = steps.where(id: task_step_ids)
    end

    if params[:inbox_id].present?
      # Filter steps from boards associated with this inbox
      board_ids = Kanban::BoardInbox.where(inbox_id: params[:inbox_id]).pluck(:board_id)
      steps = steps.where(board_id: board_ids)
    end

    @steps = steps
  end

  def show; end

  def create
    board = Current.account.kanban_boards.find(params[:board_id])
    @step = board.steps.new(step_params)
    @step.account_id = Current.account.id
    @step.save!
  end

  def update
    @step.update!(step_params)
  end

  def destroy
    @step.destroy!
    head :ok
  end

  def reorder
    board = Current.account.kanban_boards.find(params[:board_id])
    authorize [:kanban, board], :update?

    board.reorder_steps(params[:steps_order])
    head :ok
  end

  private

  def fetch_step
    @step = Current.account.kanban_board_steps.find(params[:id])
  end

  def step_params
    params.require(:step).permit(:name, :description, :color, :cancelled)
  end
end
