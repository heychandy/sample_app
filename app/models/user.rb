# == Schema Information
# Schema version: 20100329192815
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  salt               :string(255)
#

# == Schema Information
# Schema version: 20100329152317
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#
require 'digest'
class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation
  attr_accessor :password
  
  before_save :encrypt_password
  
  EmailRegex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates_presence_of :name, :email
  validates_length_of :name, :maximum => 50
  validates_format_of :email, :with => EmailRegex
  validates_uniqueness_of :email, :case_sensitive => false
  validates_presence_of :password
  validates_length_of :password, :within => 6..40
  validates_confirmation_of :password
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end
  
  private
    def encrypt_password
      self.salt = make_salt
      self.encrypted_password = encrypt(password)
    end
    def encrypt(string)
      secure_hash("#{salt}#{string}")
    end
    def make_salt
      secure_hash("#{Time.now.utc}#{password}")
    end
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
end
