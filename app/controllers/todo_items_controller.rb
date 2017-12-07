class TodoItemsController < ApplicationController

  def create
    @todo_list = TodoList.find(params[:todo_list_id])
    @todo_item = @todo_list.todo_items.create(params[:todo_item].permit(:content))
    redirect_to @todo_list
  end

  def destroy
    @todo_list = TodoList.find(params[:todo_list_id])
    @todo_item = @todo_list.todo_items.find(params[:id])
    @todo_item.destroy
    redirect_to @todo_list
  end

  def complete
    @todo_list = TodoList.find(params[:todo_list_id])
    @todo_item = @todo_list.todo_items.find(params[:id])
    @todo_item.update_attribute(:completed_at, Time.new)
    redirect_to @todo_list, notice: "Todo item completed"
  end
end
