class Api::V1::Serializers::SerializableToken < JSONAPI::Serializable::Resource

  type :tokens

  attributes :comment, :expires_at, :token

  belongs_to :user

  link(:self) { @url_helpers.api_v1_token_url(@object.id) }
  link(:delete) { @url_helpers.api_v1_token_url(@object.id) }

end
