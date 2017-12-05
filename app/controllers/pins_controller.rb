class PinsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create]
  def index
    @pins = Pin.all.order("created_at DESC")
  end

  def new
    @pin = current_user.pins.build
  end

  def create
    @pin = current_user.pins.build(pin_params)
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
    @pin.update(pin_params)
    redirect_to @pin, notice: "Pin was Successfully update!"
  end

  def destroy
    @pin = Pin.find(params[:id])
    @pin.destroy
    redirect_to root_path
  end

  private

  def pin_params
    params.require(:pin).permit(:title, :description, :image)
  end
end
