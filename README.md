---
title: How to build a Reddit or Hacker News Style Web App in Rails5
date: 2017-11-17 16:11:31
tags:
toc: true
comments: true

---

## 1.Create new projects

```
$ ruby -v
$ rails -v

$ mkdir 12_in_12_challenge
$ cd 12_in_12_challenge

$ rails new raddit
$ cd raddit
$ bundle install
```

重开`rails s`

http://localhost:3000

保存
```
$ git init
$ git status
$ git add .
$ git commit -m "Added all the things"
```

## 2.建立 Link scaffold

```
$ git checkout -b link_scaffold
$ rails generate scaffold link title:string url:string
$ rake db:migrate
```

重开`rails s`

http://localhost:3000/links

打开编辑器

Edit routes

```
resources :links
root "links#index"
```

http://localhost:3000

保存
```
$ git status
$ git add .
$ git commit -am "generate link scaffold"
```

## 3.添加 Bootstrap

gem

修改文件 Gemfile
```
+ gem 'bootstrap-sass'
```

```
$ bundle install
```

重开`rails s`

Rename app/assets/stylesheets/application.css
```
$ mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss
```

css
修改文件 app/assets/stylesheets/application.scss

```
+	@import "bootstrap-sprockets";
+	@import "bootstrap";
```

保存
```
$ git status
$ git add .
$ git commit -am "add bootstrap"
```

合并分支
```
$ git checkout master
$ git merge add_bootstrap
```

## 4.Devise function

```
$ git checkout -b Add_devise
```

Edit Gemfile
```
gem 'devise'
```
```
$ bundle install
```
```
`rails g devise:install`
```

修改文件 app/config/enviroments/development.rb
```
+	config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }end
修改文件 app/views/layous/application.html.erb
<body>
+	<% flash.each do |name, msg| %>
+		<%= content_tag(:div, msg, class: "alert alert-#{name}") %>
+	<% end %>

	<%= yield %>
</body>
```
```
$ rails g devise:views
$ rails g devise Users
$ rake db:migrate
```

重开`rails s`

http://localhost:3000/users/sign_in

注册一个用户
```
$ rails c
$ User.count
$ @user = User.first
$ exit
```

保存
```
$ git status
$ git add .
$ git commit -m "Add devise"
```

合并分支
```
$ git checkout master
$ git merge Add_devise
```

## 5.User model

确定User 与 link 的关系
```
$ git checkout -b Add_users_model
```

确定user与link的关系

Edit  user.model
```
has_many :links
```

Edit link.model
```
belongs_to :user
```
添加 user ID 到 link
Create user_id_to_links
```
$ rails g migration add_user_id_to_links user_id:integer:index
$ rake db:migrate
```
```
$ rails c
$ @link = Link.first
$ @link.user
$ exit
```

保存
```
$ git status
$ git add .
$ git commit -m "Add user model"
```

合并分支
```
$ git checkout master
$ git merge Add_users_model
```

## 6.User view

添加登录/登出按钮

Edit views/application.rb

修改文件 application.html.erb
```
	<% if user_signed_in? %>
		<ul>
			<li><%= link_to 'Submit link', new_link_path %></li>
			<li><%= link_to 'Account', edit_user_registration_path %></li>
			<li><%= link_to 'Sign out', destroy_user_session_path, :method => :delete %></li>
		</ul>
	<% else %>
		<ul>
			<li><%= link_to 'Sign up', new_user_registration_path %></li>
			<li><%= link_to 'Sign in', new_user_session_path %></li>
		</ul>
	<% end %>
	<% yield %>
```

## 7.User controller

添加授权许可：Authorization on links
```
`git checkout -b Authorization_on_links`
```

controller
修改文件 link_controller.rb
```
def new
	@link = current_user.links.build
end

def create
	@link = current_user.build(link_params)
...
end
```

终端输入
```
rails c
@link = Link.last
@link.user = User.first
@link.user.email
```

继续修改文件 links_controller.rb
```
before_action :authenticate_user!, except: [:index, :show]
```

view
修改文件 views/links/index.html.erb
```
<% if link.user == current_user %>
		<td><%= link_to 'Edit', edit_link_path(link) %></td>
		<td><%= link_to 'Destroy', link, method: :delete, data: { confirm: 'Are you sure?' } %></td>
<% end %>
```

终端输入
```
rails c
@user = User.first
@link = Link.first
@link.user = User.first
@link
@link = Link.find(2)
@link.user = User.first
@link.save
@link = Link.first
@link.user = User.first
@link.save
```

继续修改文件 views/links/links/index.html.erb
```
-	<br>
-	<%= link_to 'New Link', new_link_path %>
```

保存
```
git status
git add .
git commit -m "Authorization on links"

git checkout master
git merge Authorization_on_links
```

## 8.修改全局样式

添加结构和基本样式
Add structure and basic styling
```
git checkout -b  Add_structure_and_basic_styling
```

套上 js 套件
Edit application.js
```
+	//= require bootstrap-sprockets
```

删除文件 app/assets/stylesheets/scaffold.scss
```
`rm -rf app/assets/stylesheets/scaffold.scss`
```

刷新页面
套上 scss 套件
修改文件 app/assets/styesheets/application.css.scss
```
#logo {
 	 font-size: 26px;
 	 font-weight: 700;
 	 text-transform:uppercase;
 	 letter-spacing: -1px;
 	 padding: 15 px 0;
 	 a {
			color: #2F363E;
 		}
		}

#main_content {
		#content {
						float: none;
 				 }
 	padding-bottom: 100px;
 	.link {
			padding: 2em 1em;
				border-bottom: 1px solid #e9e9e9;
					.title {
						a {
							color: #FF4500;
							}
						}
 		 }
 	.comments_title {
						margin-top: 2em;
 					}
		#comments {
			.comments {
				padding: 1em 0;
					border-top: 1px solid #E9E9E9;
						.lead {
								margin-bottom: 0;
							}
						}
					}
				}
```

views
application.html.erb
修改文件 views/layouts/application.html.erb
```
<!DOCTYPE html>
<html>

<head>
	<title>Reddit</title>
	<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
	<%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
	<%= csrf_meta_tags %>
</head>

<body>
	<header class="navbar navbar-default" role="navigation">
		<div class='navbar-inner'>
			<div class="container">
				<div id="logo" class="navbar-brand"><%= link_to "Reddit", root_path %></div>

				<nav class="collapse navbar-collapse navbar-ex1-collapse">
					<% if user_signed_in? %>
						<ul class="nav navbar-nav pull-right">
							<li><%= link_to 'Submit link', new_link_path %></li>
							<li><%= link_to 'Account', edit_user_registration_path %></li>
							<li><%= link_to 'Sign out', destroy_user_session_path, :method => :delete %></li>
						</ul>
					<% else %>
						<ul class="nav navbar-nav pull-right">
							<li><%= link_to 'Sign up', new_user_registration_path %></li>
							<li><%= link_to 'Sign in', new_user_session_path %></li>
						</ul>
					<% end %>
				</nav>
			</div>
		</div>
	</header>

	<div id="main_content" class="container">
		<% flash.each do |name, msg| %>
			<% content_tag(:div, msg, class: "alert alert-#{name}") %>
		<% end %>

		<div id="content" class="col-md-9 center-black">
			<%= yield %>
		</div>
	</div>

</body>
</html>
```

Links
index.html.erb
修改文件 app/views/links/index.html.erb
```
<% @links.each do |link| %>
		<div class="link row clearfix">
			<h2>
				  <%= link_to link.title, link %><br>
				  <small class="author">Submitted <%=time_ago_in_words(link.created_at) %> by <%= link.user.email %></small>
			</h2>
 	 </div>
<% end %>
```

index.html.erb
修改文件 app/views/links/show.html.erb
```
<div class="page-header">
 	 <h1>
 		<a href="<%= @link.url %>"><%= @link.title %></a><br>
 		<small>Submitted by <%= @link.user.email %></small>
 	</h1>
</div>

<div class="btn-group">
		<%= link_to 'Visit URL', @link.url, class: "btn btn-primary" %>
</div>

<% if @link.user == current_user -%>
		<div class="btn-group">
 	 	<%= link_to 'Edit', edit_link_path(@link), class: "btn btn-default" %>
 	 	<%= link_to 'Destroy', @link, method: :delete, data: {confirm: 'Are you sure?' }, class: "btn btn-default" %>
 	 </div>
<% end %>
```

form.html.erb
修改文件 app/views/links/form.html.erb
```
...
<%= form_for(@link) do |f| %>
		<div class="form-group">
			<%= f.label :title %><br>
			<%= f.text_field :title, class: "form-control" %>
		</div>
		<div class="form-group">
			<%= f.label :url %><br>
			<%= f.text_field :url, class: "form-control" %>
		</div>
		<div class="form-group">
			<%= f.submit "Submit", class: "btn btn-lg btn-primary" %>
		</div>
  <% end %>
```

devise
registrations/edit.html.erb
修改文件 app/views/devise/registrations/edit.html.erb
```html
<h2>Edit <%= resource_name.to_s.humanize %></h2>

<div class="panel panel-default">

	<%= form_for(resource, as: resource_name, url: registration_path(resource_name), html: { method: :put }) do |f| %>
		<%= devise_error_messages! %>

		<div class="panel-body">
			<div class="form-inputs">
				<div class="form-group">
					<%= f.label :email %><br />
					<%= f.email_field :email, autofocus: true %>
				</div>

				<% if devise_mapping.confirmable? && resource.pending_reconfirmation? %>
					<div>Currently waiting confirmation for: <%= resource.unconfirmed_email %></div>
				<% end %>

				<div class="form-group">
					<%= f.label :password %> <i>(leave blank if you don't want to change it)</i><br />
					<%= f.password_field :password, autocomplete: "off" %>
					<% if @minimum_password_length %>
						<br />
						<em><%= @minimum_password_length %> characters minimum</em>
					<% end %>
				</div>

				<div class="form-group">
					<%= f.label :password_confirmation %><br />
					<%= f.password_field :password_confirmation, autocomplete: "off" %>
				</div>

				<div class="form-group">
					<%= f.label :current_password %> <i>(we need your current password to confirm your changes)</i><br />
					<%= f.password_field :current_password, autocomplete: "off" %>
				</div>
			</div>

			<div class="form-group">
				<%= f.submit "Update" %>
			</div>
		</div>
	<% end %>

	<div class="panel-footer">
		<h3>Cancel my account</h3>
		<p>Unhappy?
		<%= button_to "Cancel my account", registration_path(resource_name), data: { confirm: "Are you sure?" }, method: :delete %>
		</p>
	</div>

</div>
```

registration/new.html.erb
修改 app/views/devise/registrations/new.html.erb
```html
<h2>Sign up</h2>

<%= form_for(resource, as: resource_name, url: registration_path(resource_name)) do |f| %>
		<%= devise_error_messages! %>

 	<div class="form-group">
			<%= f.label :email %><br />
			<%= f.email_field :email, autofocus: true, class: "form-control", required: true %>
 	 </div>

 	 <div class="form-group">
			<%= f.label :password %>
			<% if @minimum_password_length %>
				<em>(<%= @minimum_password_length %> characters minimum)</em>
			<% end %><br />
			<%= f.password_field :password, autocomplete: "off", class: "form-control", required: true %>
 	 </div>

 	 <div class="form-group">
			<%= f.label :password_confirmation %><br />
			<%= f.password_field :password_confirmation, autocomplete: "off", class: "form-control", required: true %>
 	 </div>

 	 <div class="form-group">
			<%= f.submit "Sign up", class: "btn btn-lg btn-primary" %>
 	 </div>
<% end %>

<%= render "devise/shared/links" %>
```

sessions/new.html.erb
修改文件 app/views/devise/sessions/new.html.erb
```html
<h2>Log in</h2>

<%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>

 	 <div class="form-group">
			<%= f.label :email %><br />
			<%= f.email_field :email, autofocus: true, class: "form-control", required: false %>
 	 </div>

 	 <div class="form-group">
			<%= f.label :password %><br />
			<%= f.password_field :password, autocomplete: "off", class: "form-control", required: false %>
  	</div>

 	 <% if devise_mapping.rememberable? -%>
			<div class="form-group">
				  <%= f.check_box :remember_me %>
				  <%= f.label :remember_me %>
			</div>
 	 <% end %>

 	 <div class="form-group">
			<%= f.submit "Log in", class: "btn btn-primary" %>
 	 </div>
<% end %>

<%= render "devise/shared/links" %>
```

保存
```
git status
git add .
git commit -am "Add structure and basic styling"
```

合并
```
git checkout master
git merge Add_structure_and_basic_styling
```

## 9.添加投票功能
Add acts as votable
```
git checkout -b add_acts_as_votable
```

google搜索: acts as votable
安装gem
Edit Gemfile
```
+	gem 'acts_as_votable'
```
```
bundle install
```

重开`rails s`

数据库迁移
```
rails g acts_as_votable:migration
rake db:migrate
```

如果在rake db:migrate出现报错，可以尝试以下操作
修改文件 db/migrate/XXX_acts_as_votable_migration.rb
```ruby
-	class ActsAsVotableMigration < ActiveRecord::Migration
+	class ActsAsVotableMigration < ActiveRecord::Migration[5.1]
修改文件 config/routes.rb
-	resources :links
+	resources :links do
+		member do
+			get "like", to: "links#upvote"
+			put "dislike", to: "links#downvote"
+		end
+	end
```

MVC
Model
修改文件 app/models/link.rb
```
+	acts_as_votable
```
```
rails c
@link = Link.first
@user = User.first
@link.like_by @user
@link.votes_for.size
@link.save

rails c
@link = Link.new(:name => 'my post!' )
@link.save
@link.like_by @user
@link.votes_for.size # => 1
```

controller
修改文件 controller/links/controller.rb
```ruby
+	def upvote
+		@link = Link.find(params[:id])
+		@link.upvote_by current_user
+		redirect_to links_path
+	end

+	def downvote
+		@link = Link.find(params[:id])
+		@link.downvote_by current_user
+		redirect_to links_path
+	end

	private
...
```

view
修改文件 app/views/links/index.html.erb
```html
<% @links.each do |link| %>
 	<div class="link row cleafix">
 		<h2>
 			<%= link_to link.title, link %><br>
 			<small class="author">Submitted <%= time_ago_in_words(link.created_at) %> by <%= link.user.email %></small>
 		</h2>
 		<div class="btn-group">
 			<%= link_to like_link_path(link), nethod: :put, class: "btn btn-default btn-sm" do %>
 				<span class="glyphicon glyphicon-chevron-up" ></span>
 				Upvote
 				<%= link.get_upvotes.size %>
 			<% end %>

 			<%= link_to dislike_link_path(link), method: :put, class: "btn btn-default btn-sm" do %>
 				<span class="glyphicon glyphicon-chevron-down" ></span>
 				Downvote
 				<%= link.get_downvotes.size %>
 			<% end %>
 		</div>
 	</div>
 <% end %>
```

修改文件 app/views/links/show.html.erb
```html
...略
	end

+	<div class="btn-group pull-right">
+	  <%= link_to like_link_path(@link), method: :put, class: "btn btn-default btn-sm" do %>
+	    <span class="glyphicon glyphicon-chevron-up"></span>
+	    Upvote
+	    <%= @link.get_upvotes.size %>
+	  <% end %>
+	  <%= link_to dislike_link_path(@link), method: :put, class: "btn btn-default btn-sm" do %>
+	    <span class="glyphicon glyphicon-chevron-down"></span>
+	    Upvote
+	    <%= @link.get_downvotes.size %>
+	  <% end %>
+	</div>
```

保存
```
git status
git add .
git commit -am "Add acts as votable"
```

合并
```
git checkout master
git merge add_acts_as_votable
```

## 10.添加留言板功能
建立comment scaffold
```
rails g scaffold Comment link_id:integer:index body:text user:references --skip-stylesheets
rake db:migrate
```
重开`rails s`

打开编辑器
Edit config/routes.rb
```ruby
-	resources :comments
resources :links do
		member do
		......
		end
	+	resources :comments
	end
```
```
rake routes
```

Create gem (simple_form)
Edit Gemfile
```
+	gem 'simple_form'
```
```
bundle install
```
重开`rails s`

MVC
Model
修改文件 app/models/link.rb
```
+	has_many :comments
```

修改文件 app/models/comment.rb
```
+	belongs_to :link
```

Controller
Edit Comments_Controller.rb
```ruby
-	def index
-	  @comments = Comment.all
-	end

-	def show
-	end

-	def new
-	  @comment = Comment.new
-	end

-	def edit
-	end

	def create
+	  @link = Link.find(params[:link_id])
-		  @comment = Comment.new(comment_params)
+		  @comment = @link.comments.new(comment_params)
+	  @comment.user = current_user
...略

	end

...

-	def update
-	  ...
-	end
```

View
Edit app/views/links/show.html.erb
```html
... #加在最下面
	<h3 class="comments_title">
		  <%= @link.comments.count %> Comments
	</h3>

	<div id="comments">
		  <%= render :partial => @link.comments %>
	</div>
	<%= simple_form_for [@link, Comment.new]  do |f| %>
		  <div class="field">
			<%= f.text_area :body, class: "form-control" %>
		  </div>
		  <br>
		  <%= f.submit "Add Comment", class: "btn btn-primary" %>
	<% end %>
```

增加文件
```
touch app/views/comments/_comment.html.erb
```

修改文件 Gemfile
```
+	gem 'record_tag_helper'
```
```
bundle install
```
重开`rails s`

修改文件 app/views/comments/comment.html.erb
```html
<%= div_for(comment) do %>
 	 <div class="comments_wrapper clearfix">
 	 	<div class="pull-left">
 		 	  <p class="lead"><%= comment.body %></p>
 		 	  <p><small>Submitted <strong><%= time_ago_in_words(comment.created_at) %> ago</strong> by <%= comment.user.email %></small></p>
 	 	</div>

 	 	<div class="btn-group pull-right">
 		 	  <% if comment.user == current_user -%>
 		 		<%= link_to 'Destroy', @link, method: :delete, date: { confirm: 'Are you sure?' }, class: "btn btn-sm btn-default" %>
 		 	  <% end %>
 	 	</div>
 	 </div>
<% end %>
```
```
git status
git add .
git comment -am "Add comments"

git checkout master
git merge Add_comments
```

## 11.添加名字到用户

Add name to users
```
$ git checkout -b Add_name_to_users
$ rials g migration add_name_to_users name:string
$ rake db:migrate
```

修改文件 app/views/devise/registrations/edit.html.erb
```
<div class="form-group">
     <%= f.label :name %><br />
     <%= f.text_field :name, autofocus: true, required: true %>
</div>
```

修改文件 app/controller/application_controller.rb
```
before_action :configure_permitted_parameters, if: :devise_controller?

   protected

   def configure_permitted_parameters
   	devise_parameter_sanitizer.permit(:sign_up) do |u|
   		u.permit(:name, :email, :password, :password_confimation)
   	end

   	devise_parameter_sanitizer.permit(:account_update) do |u|
   		u.permit(:name, :email, :password, :password_confimation, :current_password)
   	end
   end
```

修改文件 app/views/links/index.html.erb
```
- <small class="author">Submitted <%=time_ago_in_words(link.created_at) %> by <%= link.user.email %></small>

+ <small class="author">Submitted <%=time_ago_in_words(link.created_at) %> by <%= link.user.name %></small>
```

修改文件 app/views/links/show.html.erb
```
<h1><a href="<%= @link.url %>"><%= @link.title %></a><br> <small>Submitted by <%= @link.user.email %></small></h1>

+ <h1><a href="<%= @link.url %>"><%= @link.title %></a><br> <small>Submitted by <%= @link.user.name %></small></h1>
```

修改文件 app/views/comments/comments.html.erb
```
-	<p><small>Submitted <strong><%= time_ago_in_words(comment.created_at) %> ago</strong> by <%= comment.user.email %></small></p>
+	<p><small>Submitted <strong><%= time_ago_in_words(comment.created_at) %> ago</strong> by <%= comment.user.name %></small></p>
```

修改文件 app/views/devise/registration/new.html.erb
```
+	<div class="form-group">
+	 	<%= f.label :name %><br />
+	 	<%= f.text_field :name, autofocus: true, class: "form-control", required: true %>
+   </div>

	<div class="form-group">
	  <%= f.label :email %><br />
	....
```

保存：
```
$ git add .
$ git commit -am "Add_name_to_users"
```
