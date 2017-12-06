class PostsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_post, only: [:show, :edit, :update, :destroy, :upvote, :downvote]
  def index
    @posts = Post.all.order("created_at DESC")
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.save
    redirect_to @post
  end

  def show
    @comments = Comment.where(post_id: @post)
    @random_post = Post.where.not(id: @post).order("RANDOM()").first
  end

  def edit
  end

  def update
    @post.update(post_params)
    redirect_to @post
  end

  def destroy
    @post.destroy
    redirect_to root_path
  end

  def upvote
    @post.upvote_by current_user
    redirect_to @post
  end

  def downvote
    @post.downvote_by current_user
    redirect_to @post
  end

  private

  def post_params
    params.require(:post).permit(:title, :link, :description, :image)
  end

  def find_post
    @post = Post.find(params[:id])
  end
end
