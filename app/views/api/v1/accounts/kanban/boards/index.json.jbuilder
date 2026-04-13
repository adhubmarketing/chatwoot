json.payload do
  json.boards @boards do |board|
    json.partial! 'api/v1/models/kanban_board', formats: [:json], resource: board
  end

  json.preferences @preferences.preferences if @preferences
end
