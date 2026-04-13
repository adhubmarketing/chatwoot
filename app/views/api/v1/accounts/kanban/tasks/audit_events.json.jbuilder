json.payload do
  json.audit_events @audit_events do |event|
    json.id event.id
    json.task_id event.task_id
    json.action event.action
    json.metadata event.metadata
    json.created_at event.created_at

    json.performed_by do
      json.partial! 'api/v1/models/agent', formats: [:json], resource: event.performed_by
    end
  end

  json.meta do
    json.current_page @audit_events.current_page
    json.total_pages @audit_events.total_pages
    json.total_count @audit_events.total_count
  end
end
