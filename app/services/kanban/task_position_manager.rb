class Kanban::TaskPositionManager
  # Inserts a task into a step at a specific position
  # @param task [Kanban::Task] The task to insert
  # @param step_id [Integer] The target step ID
  # @param before_task_id [Integer, nil] Optional task ID to insert before
  # @return [Boolean] Success status
  def insert_task(task, step_id, before_task_id: nil)
    Kanban::Task.transaction do
      if before_task_id.present?
        # Insert before specific task
        before_task = Kanban::Task.find(before_task_id)
        insert_position = before_task.position

        # Shift all subsequent tasks in the target step
        Kanban::Task.where(board_id: task.board_id, step_id: step_id)
                    .where('position >= ?', insert_position)
                    .update_all('position = position + 1')

        task.position = insert_position
      else
        # Append to end of step
        max_position = Kanban::Task.where(board_id: task.board_id, step_id: step_id).maximum(:position) || -1
        task.position = max_position + 1
      end

      true
    end
  rescue StandardError => e
    Rails.logger.error "Failed to insert task: #{e.message}"
    false
  end

  # Reorders all tasks in a step to eliminate gaps
  # @param step_id [Integer] The step ID to reorder
  # @return [void]
  def reorder_step_tasks(step_id)
    step = Kanban::BoardStep.find(step_id)
    tasks = step.tasks.order(:position)

    Kanban::Task.transaction do
      tasks.each_with_index do |task, index|
        task.update_column(:position, index) if task.position != index
      end
    end
  rescue StandardError => e
    Rails.logger.error "Failed to reorder step tasks: #{e.message}"
  end

  # Moves a task from one step to another with positioning
  # @param task [Kanban::Task] The task to move
  # @param new_step_id [Integer] The target step ID
  # @param before_task_id [Integer, nil] Optional task ID to insert before
  # @return [Boolean] Success status
  def move_task(task, new_step_id, before_task_id: nil)
    old_step_id = task.step_id

    Kanban::Task.transaction do
      # Remove from old position
      if old_step_id.present?
        Kanban::Task.where(board_id: task.board_id, step_id: old_step_id)
                    .where('position > ?', task.position)
                    .update_all('position = position - 1')
      end

      # Insert into new position
      task.step_id = new_step_id
      insert_task(task, new_step_id, before_task_id: before_task_id)

      task.save!
    end

    true
  rescue StandardError => e
    Rails.logger.error "Failed to move task: #{e.message}"
    false
  end
end
