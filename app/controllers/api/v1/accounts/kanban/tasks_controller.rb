class Api::V1::Accounts::Kanban::TasksController < Api::V1::Accounts::BaseController
  before_action :fetch_task, only: [:show, :update, :destroy, :move, :audit_events]
  before_action :check_authorization

  def index
    tasks = Current.account.kanban_tasks.includes(:assigned_agents, :contacts, :conversations, :step)

    # Apply filters
    tasks = tasks.where(board_id: params[:board_id]) if params[:board_id].present?
    tasks = tasks.where(step_id: params[:step_id]) if params[:step_id].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?

    if params[:agent_id].present?
      tasks = tasks.joins(:task_agents).where(kanban_task_agents: { user_id: params[:agent_id] })
    end

    if params[:inbox_id].present?
      # Filter tasks from boards associated with this inbox
      board_ids = Kanban::BoardInbox.where(inbox_id: params[:inbox_id]).pluck(:board_id)
      tasks = tasks.where(board_id: board_ids)
    end

    # Apply sorting
    sort_by = params[:sort_by] || 'position'
    direction = params[:direction] || 'asc'

    tasks = case sort_by
            when 'priority'
              tasks.order(priority: direction)
            when 'due_date'
              tasks.order(Arel.sql("due_date #{direction} NULLS LAST"))
            when 'created_at'
              tasks.order(created_at: direction)
            else
              tasks.order(position: direction)
            end

    # Pagination
    @tasks = tasks.page(params[:page]).per(params[:per_page] || 25)
  end

  def show; end

  def create
    board = Current.account.kanban_boards.find(task_params[:board_id])
    @task = board.tasks.new(task_params.except(:agent_ids, :contact_ids, :conversation_ids))
    @task.account_id = Current.account.id

    # Handle insert_before positioning
    if params[:insert_before_task_id].present?
      before_task = Current.account.kanban_tasks.find(params[:insert_before_task_id])
      @task.position = before_task.position
    end

    @task.save!

    # Add associations
    @task.add_agents(params[:agent_ids]) if params[:agent_ids].present?
    @task.add_contacts(params[:contact_ids]) if params[:contact_ids].present?

    # Link conversations
    if params[:conversation_ids].present?
      Conversation.where(id: params[:conversation_ids], account_id: Current.account.id)
                  .update_all(kanban_task_id: @task.id)
    end

    @task.reload
  end

  def update
    @task.update!(task_params.except(:agent_ids, :contact_ids, :conversation_ids))

    # Update agent assignments
    if params[:agent_ids]
      current_agent_ids = @task.assigned_agents.pluck(:id)
      to_remove = current_agent_ids - params[:agent_ids]
      to_add = params[:agent_ids] - current_agent_ids

      @task.remove_agents(to_remove) if to_remove.any?
      @task.add_agents(to_add) if to_add.any?
    end

    # Update contact assignments
    if params[:contact_ids]
      current_contact_ids = @task.contacts.pluck(:id)
      to_remove = current_contact_ids - params[:contact_ids]
      to_add = params[:contact_ids] - current_contact_ids

      @task.remove_contacts(to_remove) if to_remove.any?
      @task.add_contacts(to_add) if to_add.any?
    end

    # Update conversation links
    if params[:conversation_ids]
      # Remove old links
      Conversation.where(kanban_task_id: @task.id).update_all(kanban_task_id: nil)
      # Add new links
      Conversation.where(id: params[:conversation_ids], account_id: Current.account.id)
                  .update_all(kanban_task_id: @task.id)
    end

    @task.reload
  end

  def destroy
    @task.destroy!
    head :ok
  end

  def move
    step_id = params[:step_id]
    insert_before_task_id = params[:insert_before_task_id]

    @task.move_to_step(step_id, insert_before_task_id: insert_before_task_id)
    render :show
  end

  def audit_events
    @audit_events = @task.audit_events.recent.includes(:performed_by).page(params[:page]).per(50)
  end

  private

  def fetch_task
    @task = Current.account.kanban_tasks.find(params[:id])
  end

  def task_params
    params.require(:task).permit(
      :board_id,
      :step_id,
      :title,
      :description,
      :priority,
      :start_date,
      :due_date,
      :position,
      label_list: []
    )
  end
end
