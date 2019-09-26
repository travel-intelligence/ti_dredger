# encoding: utf-8
class User < ActiveRecord::Base

  has_many :tokens

  attr_accessor :email
  attr_accessor :admin

  devise(
    :ldap_authenticatable,
    :trackable
  )

  validates_presence_of :email

  def can_read_schema?(schema)
    return true if @admin
    Ability.new(self).can? :read, schema.id
  end

  # Callback called by devise_ldap_authenticable before saving a user.
  def ldap_before_save
    self.email = Devise::LDAP::Adapter.get_ldap_param(self.user_name, 'mail').first
  end

end
