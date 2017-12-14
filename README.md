## 制作收藏功能

`rails g model collect post_id:integer user_id:integer`

`rake db:migrate`

Edit app/models/collect.rb

```
	belongs_to :user
	belongs_to :post
```

Edit app/models/post.rb

```
	has_many :collects, :dependent => :destroy
	has_many :collect_users, :through => :collects,  :source => :user
```

Edit app/models/user.rb

```
	has_many :collects, :dependent => :destroy
	has_many :collect_users, :through => :collects, :source => :user

	def is_collect_of?(post)     # 判断此文章是否被收藏过（参数是post）
		collect_posts.include?(post)
	end

	def collect!(post)
		collect_posts << post
	end

	def cancel!(post)
		collect_posts.delete(post)
	end
```

Edit config/routes.rb
```
 resources :posts do
     member do
       ...(略)
       post "collect" => "posts#collect"
       post "cancel" => "posts#cancel"
     end
   end
```

Edit app/views/posts/_post.html.erb_
```
 <div class="text-right">
       ...(略)

		<% if current_user && current_user.is_collect_of?(post) %>

 		  <label class="label label-success">已收藏</label>
 		   <%= link_to cancel_post_path(post), method: :post do %>
 			    <%= image_tag "collect.png" %>
 		  <% end %>

 	<% else %>

 		  <label class="label label-warning">未收藏</label>
 		  <%= link_to collect_post_path(post), method: :post do %>

 			    <%= image_tag "cancel.png" %>
 		  <% end %>

 <% end %>

       ...（略）
     </div>
```

Edit app/controllers/posts_controller.rb_
```
 def collect
     @post = Post.find(params[:id])

     if !current_user.is_collect_of?(@post) # 如果用户未收藏过此文
       current_user.collect!(@post)
     end
     redirect_to posts_path
   end

   def cancel
     @post = Post.find(params[:id])

     if current_user.is_collect_of?(@post)
       current_user.cancel!(@post)
     end

     redirect_to posts_path
   end
```

## Ajax 按赞

Edit app/views/posts/_post.html.erb_
```
 ...(略)
- <% if current_user && current_user.is_collect_of?(post) %>
-   ...(略)
- <% end %>
	<span id="post-collect-<%= post.id %>">
         <%= render :partial => "collect", :locals => { :post => post }%>
 </span>
```
`touch app/views/posts/_collect.html.erb`
```
 <% if current_user && current_user.is_collect_of?(post) %>

   <label class="label label-success">已收藏</label>
   <%= link_to cancel_post_path(post), method: :post, :remote => true do %>
     <%= image_tag "collect.png" %>
   <% end %>

 <% else %>

   <label class="label label-warning">未收藏</label>
   <%= link_to collect_post_path(post), method: :post, :remote => true do %>

     <%= image_tag "cancel.png" %>
   <% end %>

 <% end %>
```

Edit app/controllers/posts_controller.rb_
```
 def collect
 #(略)
 - redirect_to posts_path
 end
 def cancle
 #(略)
 - redirect_to posts_path
 + render "collect"
 end
```

`touch app/views/posts/collect.js.erb`

Edit app/views/posts/collect.js.erb
```
 str = "<%=j render :partial => "collect", :locals => { :post => @post } %>"
 $("#post-collect-<%= @post.id %>").html(str);
```
