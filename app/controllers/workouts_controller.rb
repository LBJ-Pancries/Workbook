class WorkoutsController < ApplicationController
  before_action :find_workout, only: [:show, :edit, :update, :destroy]
  def index
    @workouts = Workout.all
  end

  def new
    @workout = Workout.new
  end

  def create
    @workout = Workout.new(workout_params)
    @workout.save
    redirect_to @workout
  end

  def show
  end

  def edit
  end

  def update
    @workout.update(workout_params)
    redirect_to @workout
  end

  def destroy
    @workout.destroy
    redirect_to root_path
  end

  private

  def workout_params
    params.require(:workout).permit(:date, :workout, :mood, :length)
  end

  def find_workout
    @workout = Workout.find(params[:id])
  end
end
