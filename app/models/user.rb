# encoding: utf-8
class User < ActiveRecord::Base

  has_many :tokens

  attr_accessor :admin

  devise(
    :ldap_authenticatable,
    :trackable
  )

  def can_read_schema?(schema)
    return true if @admin
    Ability.new(self).can? :read, schema.id
  end

end
