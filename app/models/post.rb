class Post < ApplicationRecord
  validates_presence_of :content
  belongs_to :user

  has_many :likes, :dependent => :destroy
  has_many :liked_users, :through => :likes, :source => :user

  has_many :collects, :dependent => :destroy
  has_many :collect_users, :through => :collects, :source => :user

  def find_like(user)
    self.likes.where( :user_id => user.id ).first
  end
end
