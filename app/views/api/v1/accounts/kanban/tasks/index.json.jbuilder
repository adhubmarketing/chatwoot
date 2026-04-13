json.payload do
  json.tasks @tasks do |task|
    json.partial! 'api/v1/models/kanban_task', formats: [:json], resource: task
  end

  json.meta do
    json.current_page @tasks.current_page
    json.total_pages @tasks.total_pages
    json.total_count @tasks.total_count
  end
end
