json.id resource.id
json.board_id resource.board_id
json.step_id resource.step_id
json.title resource.title
json.description resource.description
json.priority resource.priority
json.position resource.position
json.start_date resource.start_date
json.due_date resource.due_date
json.label_list resource.label_list
json.step_changed_at resource.step_changed_at
json.account_id resource.account_id

# Step info (if loaded)
if resource.association(:step).loaded? && resource.step.present?
  json.step do
    json.id resource.step.id
    json.name resource.step.name
    json.color resource.step.color
  end
else
  json.step nil
end

# Assigned agents
json.assigned_agents resource.assigned_agents do |agent|
  json.partial! 'api/v1/models/agent', formats: [:json], resource: agent
end

# Contacts
json.contacts resource.contacts do |contact|
  json.id contact.id
  json.name contact.name
  json.email contact.email
  json.phone_number contact.phone_number
  json.thumbnail contact.avatar_url
end

# Conversations
json.conversations resource.conversations do |conversation|
  json.id conversation.id
  json.display_id conversation.display_id
  json.status conversation.status
  json.inbox_id conversation.inbox_id
end

json.created_at resource.created_at
json.updated_at resource.updated_at
