class Post < ApplicationRecord
  belongs_to :user
  has_many :comments
  acts_as_votable

  has_attached_file :image, styles: { medium: "700*500#", small: "350*250#" }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
end
