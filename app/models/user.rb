# encoding: utf-8
require 'active_model'

class User

  include ActiveModel::Model
  # Required because some before_validations are defined in devise
  include ActiveModel::Validations
  # Required to define callbacks
  extend ActiveModel::Callbacks
  extend Devise::Models

  # Required by Devise
  define_model_callbacks :validation

  attr_accessor :email
  attr_accessor :admin

  devise(
    # :ldap_authenticatable
    # :registerable,
    # :recoverable,
    # :rememberable,
    # :trackable,
    # :validatable
  )

  validates_presence_of :email

  RELATIONAL_SCHEMA_CONTROL = 'relational_schema'

  def self.find_by_email(email)
    new(email: email)
  end

  def initialize(attributes={})
    super
    @controls ||= []
  end

  def controls=(ctrls)
    @controls = ctrls || []
  end

  def can_read_schema?(schema)
    return true if @admin
    Ability.new(self).can? :read, schema.id
  end

end
