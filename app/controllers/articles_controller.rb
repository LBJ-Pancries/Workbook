class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  def index
    if params[:category].blank?
      @articles = Article.all.order("created_at DESC")
    else
      @category_id = Category.find_by(name: params[:category]).id
      @articles = Article.where(category_id: @category_id).order("created_at DESC")
    end
  end

  def new
    @article = current_user.articles.build
  end

  def create
    @article = current_user.articles.build(params.require(:article).permit(:title, :content, :category_id))
    @article.save
    redirect_to @article
  end

  def show
    @article = Article.find(params[:id])
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    @article.update(params.require(:article).permit(:title, :content, :category_id))
    redirect_to @article
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    redirect_to root_path
  end

end
