# encoding: utf-8
require 'active_model'

class User
  include ActiveModel::Model

  attr_accessor :email
  attr_accessor :admin

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
    schema_controls = @controls.select do |label,_,_|
                        label == RELATIONAL_SCHEMA_CONTROL
                      end

    schema_controls.any? do |_,sign,params|
      sign && params['schemas'] && params['schemas'].include?(schema.id)
    end
  end
end
