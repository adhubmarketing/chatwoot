class Kanban::BoardPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    @account_user.administrator?
  end

  def update?
    @account_user.administrator?
  end

  def destroy?
    @account_user.administrator?
  end

  def toggle_favorite?
    true
  end

  def update_agents?
    @account_user.administrator?
  end

  def update_inboxes?
    @account_user.administrator?
  end

  def conversations?
    true
  end
end
