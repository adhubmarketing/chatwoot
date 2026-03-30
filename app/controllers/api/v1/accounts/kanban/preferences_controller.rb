class Api::V1::Accounts::Kanban::PreferencesController < Api::V1::Accounts::BaseController
  before_action :fetch_preferences
  before_action :check_authorization

  def update
    @preferences.update!(preferences_params)
    render json: { preferences: @preferences.preferences }
  end

  private

  def fetch_preferences
    @preferences = Kanban::AccountUserPreference.find_or_create_by(
      account_id: Current.account.id,
      user_id: Current.user.id
    )
  end

  def preferences_params
    params.require(:preferences).permit!
  end

  def check_authorization
    authorize(@preferences || Kanban::AccountUserPreference)
  end
end
