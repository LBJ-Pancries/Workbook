## 1. Create new projects

`cd 12_in_12_challenge`

`rails new jobs_board`

`cd jobs_board`

`git init`

`git add .`

`git commit -m "Initial Commit"`

`rails s`

localhost:3000

## 2. Add jobs CRUD ability

`rails g model job title:string description:text company:string url:string`

`rake db:migrate`

`rails g controller jobs`

Edit app/controllers/job_controller.rb_
```rb
def index
end
```

Edit config/routes.rb
```rb
resources :jobs
root ‘jobs#index’
```

Edit Gemfile
```
gem 'simple_form'
gem 'haml'
gem 'bootstrap-sass'
```

`bundle install`
重来`rails s`

rename app/assets/stylesheets.css to app/assets/stylesheets.scss

Edit app/assets/stylesheets.scss
```
@import "bootstrap-sprockets";
@import "bootstrap";
```

Edit app/javascripts/application.js
```
+ //= require bootstrap-sprockets
//= require turbolinks
```

`rails g simple_form:install --bootstrap`
重开`rails s`

`touch app/views/jobs/index.html.haml`

Edit app/views/jobs/index.html.haml
```haml
%h1 This is the index page
```

Edit app/controllers/job_controller.rb
```rb
before_action :find_job, only: [:show, :edit, :update, :destroy]
def show
end
def new
@job = Job.new
end
@job = Job.new(job_params_)
if @job.save
redirect_to @job_
else
render “New”
end
end
def edit
end
def update
end
def destroy
end
def destroy
end
private
def jobs_params
params.require(:job).permit(:title, :description, :company, :url)
end
def find_job
@job = Job.find(params[:id])
end
```

`touch app/views/jobs/new.html.haml`

`touch app/views/jobs/_form.html.haml`

Edit app/views/jobs/form.html.haml

```
= simple_form_for(@job, html: { class: 'form-horizontal'}) do |f|
= f.input :title, label: "Job Title"
= f.input :description, label: "Job Description"
= f.input :compay, label: "Your Company"
= f.input :url, label: "Link to Job"
%br/
= f.button :submit
```

Edit app/views/jobs/new.html.haml
```
%h1 New Job
= render 'form'
= link_to "Back", root_path
```

localhost:3000/jobs/new

`touch show`

Edit show.html.haml
```
%h1= @job.title
%p= @job.description
%p= @job.company
= link_to "Home", root_path
```

Edit app/views/jobs/index.html.haml
```
- @jobs.each do |job|
%h2= job.title
%p= job.company
= link_to "New Job", new_job_path
```

Edit app/controllers/job_controller.rb
```rb
def index
@jobs = Job.all.order("created_at DESC")
end

```

Edit app/controllers/job_controller.rb
```rb
def update
if @job.update(jobs_params)
redirect_to @job
else
render "New"
end
end

def destroy
@job.destroy
redirect_to root_path
end
```

Edit show.html.haml
```
%h1= @job.title
%p= @job.description
%p= @job.company
= link_to "Home", root_path
+ = link_to "Edit", edit_job_path(@job)
```

Edit app/views/jobs/index.html.haml
```
- @jobs.each do |job|
-     %h2= job.title
+     %h2= link_to job_title, job
%p= job.company
= link_to "New Job", new_job_path
```

`touch app/views/jobs/edit.html.haml`

Edit app/views/jobs/edit.html.haml
```
%h1 Edit Job
= render 'form'
= link_to "Back", root_path
```

Edit app/views/jobs/show.html.haml
```
%h1= @job.title
%p= @job.description
%p= @job.company
= link_to "Home", root_path
= link_to "Edit", edit_job_path(@job)
+ = link_to "Delete", job_path(@job), method: :delete, data: { confirm: "Are you sure?"}
```

`git add .`

`git commit -am "Add jobs CRUD ability"`

## 3. Add categories to jobs

`rails g model category name:string`

`rake db:migrate`

`rails g migration add_category_id_to_jobs category_id:integar`

`rake db:migrate`

Edit app/models/category.rb
```rb
has_many :jobs
```

Edit app/models/job.rb
```rb
belongs_to :category
```

```
rails c
Category
Category.create(name: "Full Time")
Category.create(name: "Part Time")
Category.create(name: "Freelance")
Category.create(name: "Consulting")
Category.all
Job
```

Edit app/views/jobs/form.html.haml
```
= simple_form_for(@job, html: { class: 'form-horizontal'}) do |f|
+ = f.collection_select :category_id, Category.all, :id, :name, {promt: "Choose a category"}
= f.input :title, label: "Job Title"
= f.input :description, label: "Job Description"
= f.input :compay, label: "Your Company"
= f.input :url, label: "Link to Job"
%br/
= f.button :submit
```

Edit app/controllers/job_controller.rb
```rb
def jobs_params
- params.require(:job).permit(:title, :description, :company, :url)
+     params.require(:job).permit(:title, :description, :company, :url, :category_id)
end
```

```
@job = Job.last
@job = Job.find(3)
@job = Job.find(2)
```

Edit app/views/layouts/application.html.haml
```
!!! 5
@html
@head
%title Ruby on Rails Jobs
= stylesheet_link_tag 'application', media: 'all', 'data-turbalinks-track' => true
= javascript_include_tag 'application', 'data-turbolinks-track' => true
= csrf_meta_tags
%body
- Category.all.each do |category|
= link_to category.name, jobs_path(category: category.name)
= yield
```

Edit app/controllers/job_controller.rb
```rb
def index
if params[:category].blank?
@jobs = Job.all.order("created_at DESC")
else
@category_id = Category.find_by(name: params[:category]).id
@jobs = Job.where(category_id: @category_id).order("created_at DESC")
end
end
```

`git add .`
`git commit -am "Add categories to jobs"`

## 4. Basic Styling for Application

Edit app/views/layouts/application.html.haml
```
!!! 5
@html
@head
%title Ruby on Rails Jobs
= stylesheet_link_tag 'application', media: 'all', 'data-turbalinks-track' => true
= javascript_include_tag 'application', 'data-turbolinks-track' => true
= csrf_meta_tags
%body
-     - Category.all.each do |category|
-         = link_to category.name, jobs_path(category: category.name)
-     = yield
%nav.navbar.navbar-default
.container
.navbar-brand Rails Jobs
%ul.nav.navbar-nav
%li= link_to "All Jobs", root_path
- Category.all.each do |category|
%li= link_to category.name, jobs_path(category: category.name)
= link_to "New Job", new_job_path, class: "navbar-text navbar-right navbar-link"
.container
.col-md-6.col-md-offset-3
= yield
```

CSS
Edit app/assets/stylesshets/application.scss
```
* {
box-sizing: border-box;
}

html {
height: 100%;
}

body {
height: 100%;
background: -webkit-linear-gradient(90deg, #1D976C 10%, #93F9B9 90%);
background:    -moz-linear-gradient(90deg, #1D976C 10%, #93F9B9 90%);
background:     -ms-linear-gradient(90deg, #1D976C 10%, #93F9B9 90%);
background:      -o-linear-gradient(90deg, #1D976C 10%, #93F9B9 90%);
background:         linear-gradient(90deg, #1D976C 10%, #93F9B9 90%);
font-family: 'Lato', sans-serif;
}

.clearfix:before,
.clearfix:after {
content: " ";
display: table;
}

.clearfix:after {
clear: both;
}

.navbar-default {
background-color: white;
border-radius: 0;
height: 80px;
padding: 15px 0;
border: none;
}

.navbar-brand {
text-transform: uppercase;
letter-spacing: -1px;
font-size: 2em;
font-weight: 300;
color: #1D976C !important;
}

#jobs {
.job {
padding: 1em 0;
border-bottom: 1px solid rgba(250,250,250, 0.5);
h2 {
font-size: 2.5em;
font-weight: 300;
margin-bottom: 0;
color: white;
a {
color: white;
}
}
p {
color: rgba(250,250,250, 0.5);
}
}
}

#links {
margin-top: 2em;
}
```

Edit app/views/jobs/index.html.haml
```
#jobs
- @jobs.each do |job|
.job
%h2= link_to job_title, job
%p= job.company
```

Edit app/views/jobs/show.html.haml
```
#jobs
.job
%h2= @job.title
%p= @job.description
%p= @job.company
%button.btn.btn-default= link_to "Apply for Job", @job.url
#links
= link_to "Home", root_path, class: "btn btn-sm btn-default"
= link_to "Edit", edit_job_path(@job), class: "btn btn-sm btn-default"
= link_to "Delete", job_path(@job), method: :delete, data: { confirm: "Are you sure?"}, class: "btn btn-sm btn-default"
```

Edit app/views/jobs/form.html.haml
```
= simple_form_for(@job, html: { class: 'form-horizontal'}) do |f|
= f.collection_select :category_id, Category.all, :id, :name, {promt: "Choose a category" }, input_html: { class: "dropdown-toggle" }
= f.input :title, label: "Job Title", input_html: { class: "form-control" }
= f.input :description, label: "Job Description", input_html: { class: "form-control" }
= f.input :compay, label: "Your Company", input_html: { class: "form-control" }
= f.input :url, label: "Link to Job", input_html: { class: "form-control" }
%br/
= f.button :submit
```

`git add .`

`git commit -am "Basic Styling for Application"`
