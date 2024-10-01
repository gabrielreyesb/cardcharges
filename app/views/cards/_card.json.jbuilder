json.extract! card, :id, :name, :account_number, :created_at, :updated_at
json.url card_url(card, format: :json)
