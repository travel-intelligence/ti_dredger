class Api::V1::ApplicationController < ::ApplicationController

  # Mapping between our model classes and their corresponding seralizers
  #
  # Result::
  # * Hash<Symbol, Class>: List of serializer classes, per model class names
  def jsonapi_class
    super.merge(
      'Token': Api::V1::Serializers::SerializableToken
    )
  end

end
