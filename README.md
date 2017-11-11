# Joblisting

## Fork专案

`git clone git@github.com:XXXXX/job-listing.git`

`cd job-listing`

`git checkout -b version-1`

`cp config/database.yml.example config/database.yml`

`bundle install`

`rails s`

## 产生一个新的空 Hello World 页面

`rails generate controller welcome`

`touch app/views/welcome/index.html.erb`

Edit app/views/welcome/index.html.erb

```
''<h1>Hello World!</h1>
```

Edit config/routes.rb

```
''root 'welcome#index'
```

## 穿衣服

### 安装 Bootstrap

1. Create Gemfile

`gem 'bootstap-sass'`

`bundle install`

`mv app/assets/stylesheets/application.css to app/assets/stylesheets/application.scss`

Edit app/assets/stylesheets/application.scss
```
''+ @import "bootstrap-sprockets";
''+ @import "bootstrap";
```

2. 添加样式

Edit app/views/layouts/application.html.erb

```
'' <body>
''     <div class="navbar navbar-default" role="navigation">
'' 	      <div class="container-fluid">
'' 		        <div class="navbar-header">
'' 		          <a href="/" class="navbar-brand">JobListing</a>
'' 		        </div>
'' 		
'' 		        <div class="collapse navbar-collapse">
'' 			          <ul class="nav navbar-nav navbar-right">
'' 				            <li><%= link_to("登入", '#')%></li>
'' 			          </ul>
'' 		        </div>
'' 	      </div>
''     </div>
''
''     <%= yield %>
''
''     <footer class="container" style="margin-top: 100px;">
'' 	      <p class="text-center">LBJ
'' 		        <br>Design by XD
'' 	      </p>
''     </footer>
```

3. Create common

`mkdir app/views/common`

`touch app/views/common/_navbar.html.erb`

Edit app/views/common/navbar.html.erb

```
''<nav class="navbar navbar-default" role="navigation">
''	<div class="container-fluid">
''		<div class="navbar-header">
''			<a class="navbar-brand" href="/">JobListing</a>
''		</div>
''		<div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
''			<ul class="nav navbar-nav navbar-right">
''				<li><%= link_to("登入", '#') %></li>
''			</ul>
''		</div>
''	</div>
''</nav>
`touch app/views/common/_footer.html.erb`
Edit footer
''<footer class="container" style="margin-top: 100px;">
''	<p class="text-center">XXX
''		<br>Design by XXX
''	</p>
''</footer>
```

Edit app/views/layouts/application.html.erb

```
''   <body>
'' 	    <%= render "common/navbar"%>
'' 	    <%= yield %>
'' 	    <%= render "common/footer"%>
''   </body>
```

```
''	<body>
''		<div class="container-fluid">
''			<%= render "common/navbar" %>
''			<%= yield %>
''		</div>
''		<%= render "common/footer" %>
''	</body>
''</html>
```

4. 保存（Save）

`git add .`

`git commit -m "add bootstrap html"`

***

### 添加 flash 功能

Edit app/assets/javascripts/application.js

```
''+ //= require bootstrap/alert
''//= require_tree .
```

`touch app/views/common/_flashes.html.erb`

Edit app/views/common/_flashes.html.erb_

```
''<% if flash.any? %>
''		<% user_facing_flashes.each do |key, value| %>
''			<div class="alert alert-dismissable alert-<%= flash_class(key) %>">
''				<button class="close" data-dismiss="alert">×</button>
''				<%= value %>
''			</div>
''		<% end %>
''<% end %>
```

`touch app/helpers/flashes_helper.rb`

Edit app/helpers/flashes_helper.rb_

```
''module FlashesHelper
''	FLASH_CLASSES = { alert: "danger", notice: "success", warning: "warning" }.freeze
''	def flash_class(key)
''		FLASH_CLASSES.fetch key.to_sym, key
''	end
''	def user_facing_flashes
''		flash.to_hash.slice "alert", "notice","warning"
''	end
''end
```

Edit app/views/layouts/application.html.erb
```
''<%= render "common/flashes" %>
''<%= yield %>
```

保存（Save）

`git add .`

`git commit -m "add bootstrap falsh function"`

***

## 安装 Devise （用户登陆功能）

Edit Gemfile

```
''	gem 'devise'
```

`bundle install`

`rails g devise:install`

`rails g devise user`

`rake db:migrate`

重启`rails s`

Edit app/views/common/_navbar.html.erb_

```
''- <li><%= link_to("登录", '#') %></li>
''+ <% if !current_user %>
''	+ <li><%= link_to("注册", new_user_registration_path) %></li>
''	+ <li><%= link_to("登录", new_user_session_path) %></li>
''+ <% else %>
''	+ <li class="dropdown">
''		+ <a href="#" class="dropdown-toggle" data-toggle="dropdown">
''			Hi!, <%= current_user.email %>
''		+ <b class="caret"></b>
''		+ </a>
''		+ <ul class="dropdown-menu">
''			+ <li><%= link_to("登出", destroy_user_session_path, method: :delete) %></li>
''		+ </ul>
''	+ </li>
''+ <% end %>
```

Edit app/assets/javascripts/application.js

```
''+ //= require bootstrap/dropdown
```

### 补丁：解决下拉菜单无法工作

Edit config/routes.rb

```
'' gem 'jquery-rails'
```

`bundle install`

重启`rails s`

Edit app/assets/javascripts/application.js

```
'' -	//= require rails_ujs
'' +	//= require jquery
'' +	//= require jquery_ujs
```

保存（Save）

`git add .`

`git commit -m "user can login/logout/signup"`

***

## 安装 SimpleForm

Edit Gemfile

```
''gem 'simple_form'
```

`bundle install`

`rails generate simple_form:install --bootstrap`

重开`rails s`

保存（Save）

`git add .`

`git commit -m "install simpleform with bootstrap"`

## 实作 Jobs 的 CRUD

0. 创建分支

`git checkout -b step1`

1. 产生 job model

`rails g model job title:string description:text`

`rake db:migrate`

2. 产生 jobs_controller_

`rails g controller jobs`

3. 加上 jobs routing

Edit config/routes.rb

```
'' resources :jobs
```

4. 实作 jobs#show action

新增 show 的 action

Edit app/controllers/jobs_contrller.rb_

```
''	def show
''		@job = Job.find(params[:id])
''	end
```

新增 show 的 view

`touch app/views/jobs/show.html.erb`

Edit app/views/jobs/show.html.erb

```
''<h1><%= @job.title %></h1>
''<p><%= simple_format(@job.description) %></p>
```

5. 实作 jobs#index action

新增 index action

Edit app/controllers/jobs_controller.rb_

```
''def index
''		@jobs = Job.all
''end
```

新增 index 的 views

`touch app/views/jobs/index.html.erb`

Edit app/views/jobs/index.html.erb

```
''	<table class="table table-bordered">
'' 	  <% @jobs.each do |job| %>
'' 		  <tr>
'' 			<td><%= link_to(job.title, job_path(job)) %></td>
'' 			<td><%= job.created_at %></td>
'' 		  </tr>
'' 	  <% end %>
'' </table>
```

6. 打开 rails console 新增两笔资料

```
'' rails c
'' Job.create!(:title => "Foo", :description => "Bar")
'' Job.create!(:title => "Bar", :description => "Foo")
'' exit
```

http://localhost:3000/jobs

7. 将 root 改到 jobs#index

```
''root 'jobs#index'
```

http://localhost:3000

8. 完成jobs#new 与 jobs#create 的功能

Edit app/controllers/jobs_controller.rb_

```
''	def new
''		@job = Job.new
''	end
''	def create
''		@job = Job.new(job_params)
''		if @job.save
''			redirect_to jobs_path
''		else
''			render :new
''		end
''  end
''	private
''	def job_params
''		params.require(:job).permit(:title, :description)
''	end
```

Edit app/views/new.html.erb

```
''<h1>Add a job</h1>
''<%= simple_form_for @job do |f| %>
''		<%= f.input :title %>
''		<%= f.input :description %>
''		<%= f.submit "Submit" %>
''<% end %>
```

8. 添加 Add a job 按钮

Edit app/views/jobs/index.html.erb

```
''<div class="pull-right">
''		<%= link_to("Add a job", new_job_path, :class => "btn btn-default" )%>
''</div>
```

9. 完成 job#edit 与 jobs#update 的功能

Edit app/controllers/jobs_controller.rb_

```
''def edit
''		@job = Job.find(params[:id])
''end
''
''def update
''		@job = Job.find(params[:id])
''		if @job.update(job_params)
''			redirect_to jobs_path
''		else
''			render :edit
''		end
''end
```

Edit app/views/jobs/edit.html.erb

```
''	<h1>Edit a job</h1>
''	<%= simple_form_for @job do |f| %>
''		<%= f.input :title %>
''		<%= f.input :description %>
''		<%= f.submit "Submit" %>
''	<% end %>
```

Edit app/views/jobs/index.html.erb
```
''<table class="table table-boldered">
''	<% @jobs.each do |job| %>
''	<tr>
''		<td><%= link_to(job.title, job_path(job)) %></td>
''		<td>
''			<%= link_to("Edit", edit_job_path(job)) %>|
''			<%= link_to("Destroy", job_path(job), :method => :delete, :data => { :confirm => "Are you sure?" }) %>
''		</td>
''		<td><%= job.created_at %></td>
''	</tr>
''<table>
```

10. Jobs 必须要有标题

Edit app/models/job.rb

```
''	validates :title, presence: true
```

11. jobs#destroy

Edit app/controllers/jobs_controller.rb_

```
''	def destroy
''		@job = Job.find(params[:id])
''		@job.destroy
''		redirect_to jobs_path
''	end
```

12. 限制 new/create/update/edit/destroy 动作必须要进行登入

Edit app/controllers/jobs_controller.rb_

```
''before_action :authenticate_user!, only: [:new, :create, :update, :edit, :destroy]
```

13. git 存档

`git add .`

`git commit -m "implement job CRUD"`

## 实作 Admin 的 CRUD

### Controller/routes/views

1. Controller/routes/views

`rails g controller admin::jobs`

Edit config/routes.rb

```
''namespace :admin do
''     resources :jobs
''end
```

Edit app/controller/admin/jobs_controller.rb

```
''class Admin::JobsController < ApplicationController
''   before_action :authenticate_user!, only: [:new, :create, :update, :edit, :destroy]
''
''   def show
''     @job = Job.find(params[:id])
''   end
''
''   def index
''     @jobs = Job.all
''   end
''
''   def new
''     @job = Job.new
''   end
''
''   def create
''     @job = Job.new(job_params)
''
''     if @job.save
''       redirect_to admin_jobs_path
''     else
''       render :new
''     end
''   end
''
''   def edit
''     @job = Job.find(params[:id])
''   end
''
''   def update
''     @job = Job.find(params[:id])
''     if @job.update(job_params)
''       redirect_to admin_jobs_path
''     else
''       render :edit
''     end
''   end
''
''   def destroy
''     @job = Job.find(params[:id])
''
''     @job.destroy
''
''     redirect_to admin_jobs_path
''   end
''
''   private
''
''   def job_params
''     params.require(:job).permit(:title, :description)
''   end
'' end
```

Edit app/views/jobs/index.html.erb

```
''<div class="pull-right">
''   <%= link_to("Add a job", new_admin_job_path, :class => "btn btn-default" ) %>
'' </div>
''
'' <br><br>
''
'' <table class="table table-bordered">
''   <% @jobs.each do |job| %>
''   <tr>
''     <td>
''       <%= link_to(job.title, admin_job_path(job)) %>
''     </td>
''     <td>
''       <%= link_to("Edit", edit_admin_job_path(job)) %>
''       <%= link_to("Destroy", admin_job_path(job), :method => :delete, :data => { :confirm => "Are you sure?" }) %>
''     </td>
''     <td>
''       <%= job.created_at %>
''     </td>
''   </tr>
''   <% end %>
'' </table>
```

Edit app/views/jobs/new.html.erb

```
''<h1> Add a job </h1>
''
'' <%= simple_form_for [:admin,@job] do |f| %>
''
'' <%= f.input :title %>
'' <%= f.input :description %>
''
''   <%= f.submit "Submit" %>
'' <% end %>
```

Edit app/views/jobs/show.html.erb

```
''<h1> <%= @job.title %> </h1>
''
'' <p>
''   <%= simple_format(@job.description) %>
'' </p>
```

Eidt app/views/jobs/edit.html.erb

```
''<h1> Edit a job </h1>
''
'' <%= simple_form_for [:admin, @job ] do |f| %>
''
''  <%= f.input :title %>
''  <%= f.input :description %>
''  <%= f.submit "Submit" %>
'' <% end %>
```
