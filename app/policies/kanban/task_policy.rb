class Kanban::TaskPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
    true
  end

  def destroy?
    @account_user.administrator? || task_creator?
  end

  def move?
    true
  end

  def audit_events?
    true
  end

  private

  def task_creator?
    return false unless record.audit_events.exists?

    created_event = record.audit_events.find_by(action: 'created')
    created_event&.performed_by_id == @user.id
  end
end
