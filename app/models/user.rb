class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :posts

  has_many :likes, :dependent => :destroy
  has_many :liked_posts, :through => :likes, :source => :post

  has_many :collects, :dependent => :destroy
  has_many :collect_posts, :through => :collects, :source => :post

  def is_collect_of?(post) # 判断此文章是否被收藏过 （参数是post）
    collect_posts.include?(post)
  end

  def collect!(post) # 收藏
    collect_posts << post
  end

  def cancel!(post) # 从收藏中移除
    collect_posts.delete(post)
  end

  def display_name
    # # 取email 的前半显示，如果你也可以另开一个字段是 nickname 让用户可以自己编辑显示名称
    self.email.split("@").first
  end


end
