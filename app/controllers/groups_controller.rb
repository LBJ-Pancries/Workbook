class GroupsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  def index
    @groups = Group.all.order("created_at DESC")
  end

  def new
    @group = current_user.groups.build
  end

  def create
    @group = current_user.groups.build(group_params)

    if @group.save
      redirect_to groups_path
    else
      render :new
    end
  end

  def show
    @group = Group.find(params[:id])
  end

  def edit
    @group = Group.find(params[:id])
    if current_user != @group.user
      redirect_to root_path, alert: "You have no permission."
    end
  end

  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to groups_path, notice: "Update Success"
    else
      render :edit
    end
  end

  def destroy
    @group = Group.find(params[:id])
    @group.destroy
    redirect_to groups_path
    flash[:alert] = "Group deleted"
  end

  private

  def group_params
    params.require(:group).permit(:title, :description)
  end
end
