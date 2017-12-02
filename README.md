---
title: How to build a Workout Log in Rails5
date: 2017-11-17 16:14:02
tags:
---
## 1. Create new projects

`cd 12_in_12_challenge`

`rails new workout_log`

`cd workout_log`

`git init`

`git add .`

`git commit -m "Initial Commit"`

`rails s`

localhost:3000

## 2. Initial Commit & Workout Model

`rails g model workout date:datetime workout:string mood:string
length:string`

`rake db:migrate`

`git add .`

`git commit -am "Initial Commit & Workout Model"`

## 3. Workout controller & routes

`rails g controller workouts`

Edit config/routes.rb
```
resources :workouts
root 'workouts#index'
```

Edit app/controller/workouts_controller.rb
```
def index
end
```

`git add .`

`git commit -am "Workout controller & routes"`

## 4. Add App Gems & workout Forms/Views

Edit Gemfile
```
gem 'haml'
gem 'simple_form'
gem 'bootstrap-sass'
```

`bundle install`

重开`rails s`

rename `app/assets/stylesheet/application.css` to `app/assets/stylesheet/application.scss`

Edit app/assets/stylesheet/application.scss
```
@import "bootstrap-sprockets";
@import "bootstrap";
```

Edit app/views/assets/javascripts/application.js
```
    //= require jquery_ujs
+    //= require bootstrap-sprockets
```

`rails generate simple_form:install --bootstrap`

`touch app/views/welcome/index.html.haml`

Edit app/views/welcome/index.html.haml
```
%h1 This is the Workouts#index placeholder
```

Edit app/controller/workouts_controller.rb_
```
...
    def new
        @workout = Workout.new
    end
    def create
        @workout = Workout.new(workout_params)
        if @workout.save
            redirect_to @workout
        else
            render 'new'
        end
    end
    private
    def workout_params
        params.require(:workout).permit(:date, :workout, :mood, :length)
    end
end
```

`touch app/views/workout/_form.html.haml`

Edit app/views/workout/form.html.haml
```
= simple_form_for(@workout, html: { class: 'form-horizontal' }) do |f|
    = f.input :date, label: "Date"
    = f.input :workout, label: "What area did you workout?", input_html: { class: "form-control" }
    = f.input :mood, label: "How were you feeling?", input_html: { class: "form-control" }
    = f.input :length, label: "How long was the workout?", input_html: { class: "form-control" }
    %br/
    = f.button :submit
```

`touch app/views/workout/new.html.haml`

Edit app/views/workout/new.html.haml
```
%h1 New Workout
= render 'form'
= link_to "Cancel", root_path
```

`touch app/views/workout/show.html.haml`

Edit app/views/workout/show.html.haml
```
#workout
    %p= @workout.date
    %p= @workout.workout
    %p= @workout.mood
    %p= @workout.length
```

Edit app/controller/workouts_controller.rb_
```
before_action :find_workout, only:  [:show, :edit, :update, :destroy]
...
    def show
    end
    def edit
    end
    def update
    end
    def destroy
    end
    private
    def find_workout
        @workout = Workout.find(params[:id])
    end
end
```

`git add .`

`git commit -am "Add App Gems & workout Forms/Views"`

## 5. Loop workouts on Workouts#Index

Edit app/views/workout/index.html.erb
```
- @workouts.each do |workout|
    %p= workout.date
    %p= workout.workout
```

Edit app/controller/workouts_controller.rb_
```
def index
    @workouts = Workout.all
end
```

```
def index
    @workouts = Workout.all.order("created_at DESC")
end
```

`git add .`

`git commit -am "Loop workouts on Workouts#Index"`

## 6. Add edit & destroy ability

Edit app/controller/workouts_controller.rb_
```
before_action :find_workout, only:  [:show, :edit, :update, :destroy]
...
    def show
    end
    def edit
        if @workout.update(workout_params)
            redirect_to @workout
        else
            render 'edit'
        end
    end
    def update
    end
    def destroy
    end
    private
    def find_workout
        @workout = Workout.find(params[:id])
    end
end
```

Edit app/views/workout/show.html.haml
```
#workout
    %p= @workout.date
    %p= @workout.workout
    %p= @workout.mood
    %p= @workout.length
= link_to "Back", root_path |
= link_to "Edit", edit_workout_path(@workout)
```

`touch app/views/workout/edit.html.haml`

Edit app/views/workout/edit.html.haml
```
%h1 Edit Workout
= render 'form'
= link_to "Cancel", root_path
```

Edit app/controller/workouts_controller.rb_
```
def destroy
    @workout.destroy
    redirect_to root_path
end
```

Edit app/views/workout/show.html.haml
```
#workout
    %p= @workout.date
    %p= @workout.workout
    %p= @workout.mood
    %p= @workout.length
= link_to "Back", root_path |
= link_to "Edit", edit_workout_path(@workout) |
= link_to "Delete", workout_path(@workout), method: :delete, data: { confirm: "Are you sure?" }
```

`git add .`

`git commit -am "Add edit & destroy ability"`

## controller 优化参考

```
class WorkoutsController < ApplicationController
  def index
    @workouts = Workout.all
  end
''
  def new
    @workout = Workout.new
  end
''
  def create
    @workout = Workout.new(params.require(:workout).permit(:date, :workout, :mood, :length))
    @workout.save
    redirect_to @workout
  end
''
  def show
    @workout = Workout.find(params[:id])
  end
''
  def edit
    @workout = Workout.find(params[:id])
  end
''
  def update
    @workout = Workout.find(params[:id])
    @workout.update(params.require(:workout).permit(:date, :workout, :mood, :length))
    redirect_to @workout
  end
''
  def destroy
    @workout = Workout.find(params[:id])
    @workout.destroy
    redirect_to root_path
  end
end
```

优化
```
class WorkoutsController < ApplicationController
  before_action :find_workout, only: [:show, :edit, :update, :destroy]
  def index
    @workouts = Workout.all
  end
''
  def new
    @workout = Workout.new
  end
''
  def create
    @workout = Workout.new(workout_params)
    @workout.save
    redirect_to @workout
  end
''
  def show
  end
''
  def edit
  end
''
  def update
    @workout.update(workout_params)
    redirect_to @workout
  end
''
  def destroy
    @workout.destroy
    redirect_to root_path
  end
''
  private
''
  def workout_params
    params.require(:workout).permit(:date, :workout, :mood, :length)
  end
''
  def find_workout
    @workout = Workout.find(params[:id])
  end
end
```

## 7. Basic structure

Edit app/views/layouts/application.html.haml
```
!!!
%html
%head
    %title Workout Log Application
    = stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track' => true
    = javascript_unclude_tag 'application', 'data-turbolinks-track' => true
    = csrf_meta_tags
%body
    = yield
```

```
%body
    %nav.navbar.navbar-default
        .container
            .navbar-header
                = link_to "Workout Log", root_path, class: "navbar-brand"
    .container
        = yield
```

```
%body
    %nav.navbar.navbar-default
        .container
            .navbar-header
                = link_to "Workout Log", root_path, class: "navbar-brand"
            .nav.navbar-nav.navbar-right
                = link_to "New Workout", new_workout_path, class: "nav navbar-link"
    .container
        = yield
```

`git add .`

`git commit -am "Basic structure"`

## 8. Add exercises to workouts

`rails g model exercise name:string sets:integer reps:integer workout:references`

`rake db:migrate`

Edit app/models/workout.rb
```
has_many :exercises
```

Edit config/routes.rb
```
    resources :workouts do
        resources :exercises
    end
```

`rails g controller exercises`

Edit app/controller/exercises_controller.rb
```
def create
    @workout = Workout.find(params[:workout_id])
    @exercise = @workout.exercises.create(params[:exercises].permit(:name, :sets, :reps))
    redirect_to workout_path(@workout)
end
```

`touch app/views/exercises/_exercise.html.haml`

`touch app/views/exercises/_form.html.haml`

Edit app/views/exercises/form.html.haml
```
= simple_form_for([@workout, @workout.exercises.build]) do |f|
    = f.input :name, input_html: { class: "form-control" }
    = f.input :sets, input_html: { class: "form-control" }
    = f.input :reps, input_html: { class: "form-control" }
    %br/
    = f.button :submit
```

Edit app/views/exercises/exercise.html.haml
```
%p= exercise.name
%p= exercise.sets
%p= exercise.reps
```

Edit app/views/workout/show.html.haml
```
#workout
    %p= @workout.date
    %p= @workout.workout
    %p= @workout.mood
    %p= @workout.length

#exercises
    %h2 Exercises
    = render @workout.exercises

    %h3 Add an exercise
    = render "exercises/form"

= link_to "Back", root_path |
= link_to "Edit", edit_workout_path(@workout)
= link_to "Delete", workout_path(@workout), method: :delete, data: { confirm: "Are you sure?" }
```

Edit app/models/workout.rb
```
has_many :exercises, dependent: :destroy
```

`git add .`

`git commit -am "Add exercises to workouts"`

## 9. Change DateTime Formatting

Edit app/views/workout/index.html.erb
```
- @workouts.each do |workout|
-    %h2= link_to workout.date, workout
+    %h2= link_to workout.date.strftime("%A %B %d"), workout
    %h3= workout.workout
```

`git add .`

`git commit -am "Change DateTime Formatting"`

## 10. A little bit of styling

Edit app/assets/stylesheets/application.html.haml
```
...
html {
    height: 100%;
}
body {
       background: -webkit-linear-gradient(90deg, #616161 10%, #9bc5c3 90%); /* Chrome 10+, Saf5.1+ */
    background:    -moz-linear-gradient(90deg, #616161 10%, #9bc5c3 90%); /* FF3.6+ */
    background:     -ms-linear-gradient(90deg, #616161 10%, #9bc5c3 90%); /* IE10 */
    background:      -o-linear-gradient(90deg, #616161 10%, #9bc5c3 90%); /* Opera 11.10+ */
    background:         linear-gradient(90deg, #616161 10%, #9bc5c3 90%); /* W3C */
}

.navbar-default {
    background: rgba(250, 250, 250, 0.5);
    -webkit-box-shadow: 0 1px 1px 0 rgba(0,0,0,.2);
    box-shadow: 0 1px 1px 0 rgba(0,0,0,.2);
    border: none;
    border-radius: 0;
}
```

Edit app/views/workout/index.html.erb
```
#index_workouts
    - @workouts.each do |workout|
        %h2= link_to workout.date.strftime("%A %B %d"), workout
        %h3= workout.workout
```

Edit app/assets/stylesheets/application.html.haml
```
...
#index_workouts {
    h2 {
        margin-bottom: 0;
        font-weight: 100;
        a {
            color: white;
        }
        h3 {
            margin: 0;
            font-size: 18px;
            span {
                color: rgb(48, 181, 199);
            }
        }
    }
}
```

Edit app/views/workout/index.html.erb
```
#index_workouts
    - @workouts.each do |workout|
        %h2= link_to workout.date.strftime("%A %B %d"), workout
        %h3
            %span Workout:
            = workout.workout
```

```
.navbar-default {
    background: rgba(250, 250, 250, 0.5);
    -webkit-box-shadow: 0 1px 1px 0 rgba(0,0,0,.2);
    box-shadow: 0 1px 1px 0 rgba(0,0,0,.2);
    border: none;
    border-radius: 0;
+    .navbar-header {
        .navbar-brand {
            font-size: 20px;
            text-transform: uppercase;
            font-weight: 700;
            letter-spacing: -1px;
        }
    }
+    .navbar-link {
           line-height: 3.5;
           color: rgh(48, 181, 199);
       }
}
```

`git add .`

`git commit -am "A little bit of styling"`
