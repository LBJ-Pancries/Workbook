class PinsController < ApplicationController
  def index
    @pins = Pin.all.order("created_at DESC")
  end

  def new
    @pin = Pin.new
  end

  def create
    @pin = Pin.new(params.require(:pin).permit(:title, :description))
    @pin.save
    redirect_to @pin, notice: "Pin was Successfully create!"
  end

  def show
    @pin = Pin.find(params[:id])
  end

  def edit
    @pin = Pin.find(params[:id])
  end

  def update
    @pin = Pin.find(params[:id])
    @pin.update(params.require(:pin).permit(:title, :description))
    redirect_to @pin, notice: "Pin was Successfully update!"
  end

  def destroy
    @pin = Pin.find(params[:id])
    @pin.destroy
    redirect_to root_path
  end
end
