json.payload do
  json.conversations @conversations do |conversation|
    json.partial! 'api/v1/models/conversation', formats: [:json], resource: conversation
  end

  json.meta do
    json.current_page @conversations.current_page
    json.total_pages @conversations.total_pages
    json.total_count @conversations.total_count
  end
end
