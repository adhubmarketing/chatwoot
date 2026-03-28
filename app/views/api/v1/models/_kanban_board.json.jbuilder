json.id resource.id
json.name resource.name
json.description resource.description
json.settings resource.settings
json.steps_order resource.steps_order
json.account_id resource.account_id

# Assigned agents
json.assigned_agents resource.assigned_agents do |agent|
  json.partial! 'api/v1/models/agent', formats: [:json], resource: agent
end

# Assigned inboxes
json.assigned_inboxes resource.assigned_inboxes do |inbox|
  json.id inbox.id
  json.name inbox.name
  json.channel_type inbox.channel_type
end

# Steps summary
if resource.association(:steps).loaded?
  json.steps_summary resource.steps.map { |step|
    {
      id: step.id,
      name: step.name,
      color: step.color,
      tasks_count: step.tasks_count,
      cancelled: step.cancelled
    }
  }
else
  json.steps_summary []
end

# Total tasks count
json.total_tasks_count resource.tasks.count

json.created_at resource.created_at
json.updated_at resource.updated_at
