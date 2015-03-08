# encoding: utf-8
require 'active_model'

class User
  include ActiveModel::Model

  attr_accessor :email
  validates_presence_of :email

  def self.find_by_email(email)
    new(email: email)
  end
end
