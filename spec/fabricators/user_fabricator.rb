# encoding: utf-8

Fabricator(:user) do
  email 'user@localdomain.local'
end

Fabricator(:user_market, from: :user) do
  controls [
    [User::RELATIONAL_SCHEMA_CONTROL, true, { 'schemas' => ['MARKET'] }]
  ]
end
