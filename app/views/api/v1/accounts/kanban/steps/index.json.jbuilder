json.payload @steps do |step|
  json.partial! 'api/v1/models/kanban_step', formats: [:json], resource: step
end
