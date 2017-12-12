

## 1. 抓取第三方资料


### 1-1 实作目标

串接 聚合数据 全国天气预报 的 API，存下所有城市资料，并更新指定城市的天气信息。

### 1-2 抓天气资讯

如果要用程序抓天气资讯，要怎么抓呢?

我们可能先想到气象局，那先去 `http://www.cma.gov.cn/2011qxfw/2011qtqyb/` 逛逛，找到 北京 天气这一页有气温资料，让我们写个程序来抓吧：
首先安装 `rest-client` 这个 gem，可以让我们用 Ruby 发送 HTTP 请求：

在 Terminal 里面执行：`gem install rest-client`你应该会看到`Successfully installed rest-client-2.0.1` 的讯息。

接着开一个 irb 实验看看，执行 irb 后，输入以下ruby程序(请一行一行输入)：
```
require 'rest-client'
response = RestClient.get "http://www.weather.com.cn/weather1d/101010100.shtml"
response.body
```

哇，头晕了，这资料怎么这么乱。

这是因为回传的内容 HTML 是给浏览器显示用的，包括各种排版颜色字号的等等资料。

而我们只想到气温，在这里面比对出单纯的气温资料，是个苦逼工啊。
让我们努力看看：
```
require 'nokogiri'
doc = Nokogiri::HTML.parse(response.body)
doc.css(".today .tem").map{ |x| x.text }  # 得到 ["\n13°C\n", "\n2°C\n", "\n"]
```

透过 Nokogiri 这个库可以帮助我们解析 HTML，透过 CSS selector 从文件中比对出想要的资讯。

以上这种方式就叫做网络爬虫(web crawler)，但是这种方式不但辛苦，而且如果万一对方改了网址、调整了 HTML 结构，这段程式就很容易坏掉。

那怎么办？

我们希望能够用 API 来存取资料。

### 1-3 什么是 API?

API(Application Programming Interface)讲的就是程序跟程序的接口，定义接口叫什么名字、要传什么参数进去、它会回传什么东西回来、可能会发生的错误等等。


在写 Ruby 程序的时候，我们会呼叫库(library)的方法，这时候 API 指的是方法(method)的名字、参数、回传值等等，例如 Ruby Hash 的 API 文件。

对 Web 应用来说，客户端和服务器之间是用 HTTP 通讯协定：抓资料的一方叫做 Client 客户端，送出 HTTP request，在之前的课程中，这个角色就是浏览器，在这堂课中，我们会自己撰写 Ruby 程序作为客户端。

回传资料的一方叫做 server 服务端，回传 HTTP response，服务端例如我们已经学过的 Ruby on Rails。

Web 应用的 API 就是在定义网址 URL 长怎样、请求的 HTTP 方法(GET或POST等)是什么、要传什么参数过去、返回的资料格式又是什么。

这份教材要示范的，就是属于这一种 API。

其中返回格式最常用的是 JSON 或 XML。

这两种是最常见的资料交换格式，专门用来让机器之间交换资料用的，只有纯粹的资料，不像 HTML 有没有杂七杂八的排版资讯。

一个 JSON 字串例如：
```
{ "id": 123, "name": "foobar"}
```
就是在描述一个哈希，不同程式语言都可以产生和解析这一个字串，让我们在 irb 中实验看看，我们可以把任意的 Ruby 资料，转成 JSON 字串：
```
require 'json'
{ :id => 123, :name => "foobar" }.to_json       # => "{\"id\":123,\"name\":\"foobar\"}"
```

你可以再开另一个 Terminal，再进入 irb，把刚刚的 JSON 字串贴上来
```
require 'json'
JSON.parse( "{\"id\":123,\"name\":\"foobar\"}" )   # => {"id"=>123, "name"=>"foobar"}
```

这样就又把 JSON 字串又转回 Ruby 了。

所以如果能有 Web API 提供 JSON 资料的话，就可以透过程式语言直接解析拿到纯粹的资料，非常方便又可靠。

### 1-4 注册聚合数据，拿到 API Key

让我们找找看有没有提供天气 API 的服务商，找到了由聚合数据提供的 全国天气预报 API，请先注册，然后申请天气预报数据：

然后就可以拿到 API Key，请记下这个凭证，等会呼叫 API 时会用到:

API 服务商都会要求你先注册，然后呼叫 API 时需要带着这个 API Key 参数，用来记录呼叫者和使用次数。


### 1-5 安装 Postman 进行初步测试

要怎么对 Web API 进行手动的测试呢?

我们来装一个 Chrome Extension 叫做 Postman，这就是一个万用的表单工具。

首先进入 Chrome 选单上的 Windows > Extensions，然后安装 Postman：

透过这个工具，我们可以指定 URL 地址、HTTP 方法和要传递的参数。

让我们实验看。

根据 全国天气预报 文档 的说明，让我们试试看来抓「支持城市列表」

在 Postman 中输入接口的 URL 地址和参数：

点击 Send 就可以看到结果了：

### 1-6 用 rest-client 抓下来观察看看

接下来实验 Ruby 客户端，用 Ruby 程序来抓取上述的资料。
进入 irb：
```
require 'rest-client'
require 'json'
response = RestClient.get "http://v.juhe.cn/weather/citys", :params => { :key => "請換成你的Key" }    
data = JSON.parse(response.body)
```

这个 data 变量就是单纯的 Ruby 哈希资料了，是全部的城市。接下来我们可以观察一下这个资料的样子，文档上面也有范例：
```
data.keys          # => ["resultcode", "reason", "result", "error_code"]
data["result"][0]  # => {"id"=>"1", "province"=>"北京", "city"=>"北京", "district"=>"北京"}
```

## 2. 串接第三方 API 服务

### 2-1 目标

上一章我们已经可以用 Ruby 程序抓到资料了，这一章我们将整合进 Rails，将抓到的资料存进数据库，并且可以更新天气资讯。
1. 建立一个 City model，然后把 API 抓取回来的城市资料存进数据库
2. 新增 cities controller 和页面，让用户可以浏览城市资料
3. 用户可以更新指定城市的气温资讯

### 2-2 初始专案，建立 City Model

在 Terminal 下输入：
```
 rails new api_exercise
 cd api_exercise
 git init
```

编辑 Gemfile 加上 gem 'rest-client'，然后执行 bundle
执行 rails g model city
编辑 city 的 migration 档案 `db/migrate/201703XXXXXXXX_create_cities.rb：`
```
db/migrate/201703XXXXXXXX_create_cities.rb
 class CreateCities < ActiveRecord::Migration[5.0]
   def change
     create_table :cities do |t|
+      t.string :juhe_id
+      t.string :province
+      t.string :city
+      t.string :district
+      t.string :current_temp
       t.timestamps
     end


+    add_index :cities, :juhe_id
   end
 end
```

接着执行 rake db:migrate 建立数据库 table。

### 2-3 抓取城市资料储存下来

新增 `lib/tasks/dev.rake`，放在这个目录下的 rake 档案是用来编写任务脚本，让我们在 Terminal 中可以执行它：
lib/tasks/dev.rake
```
namespace :dev do
  task :fetch_city => :environment do
    puts "Fetch city data..."
    response = RestClient.get "http://v.juhe.cn/weather/citys", :params => { :key => "你申请的key放这里" }
    data = JSON.parse(response.body)


    data["result"].each do |c|
      existing_city = City.find_by_juhe_id( c["id"] )
      if existing_city.nil?
        City.create!( :juhe_id => c["id"], :province => c["province"],
                      :city => c["city"], :district => c["district"] )
      end
    end


    puts "Total: #{City.count} cities"
  end
end
```

执行 `bundle exec rake dev:fetch_city` 就会执行这个任务，把 2574 笔城市存进数据库。
`juhe_id` 这个栏位的目的是存下第三方那边的`id`，这样我们之后在更新数据的时候，就可以进行比对、避免重复新增。

这里省略了安装 Bootstrap 的步骤，如果没安装也没关系，画面会有差异而已。

### 2-5 更新城市天气

我们希望存下来当前温度。根据 文档 的说明，可以找到气温的 API 说明。
首先修改 config/routes.rb，新增一个操作：
`config/routes.rb`
```
-  resources :cities
+  resources :cities do
+    member do
+      post :update_temp
+    end
+  end
```

在画面上放一个按钮，编辑 app/views/cities/index.html.erb
`app/views/cities/index.html.erb`
```
- <td></td>
+ <td>
+   <%= city.current_temp %>
+   <%= link_to "更新温度", update_temp_city_path(city), :method => :post %>
+ </td>
```

新增一个 action，编辑 app/controller/cities_controller.rb
app/controller/cities_controller.rb
```
defupdate_temp
    city=City.find(params[:id])


    response=RestClient.get"http://v.juhe.cn/weather/index",
                              :params=>{:cityname=>city.juhe_id,:key=>"你申请的key放这里"}
    data=JSON.parse(response.body)


    city.update(:current_temp=>data["result"]["sk"]["temp"])


    redirect_tocities_path
end
```

这样点击「更新温度」后，就会更新气温了。

### 2-6 保护 API Key

在串接第三方应用时，第三方的 API Key 我们不希望写死在程式码里面，一来是因为我们不想把这些敏感的 keys 放到版本控制系统里面。二来是因为将来布署的时候，在 production 环境下，api key 会另外申请一个不一样，因此我们希望容易抽换。
新增 config/juhe.yml 作为设定档，内容如下：
```
development:
  api_key: "你申请的key放这里"
production:
  api_key: "之后布署上production的话，key放这里"
```

编辑 config/application.rb，在最下面插入一行：
config/application.rb
```
# (略)
JUHE_CONFIG = Rails.application.config_for(:juhe)
```



编辑 `app/controller/cities_controller.rb` 和 `lib/tasks/dev.rake`，把 `"你申请的key放这里"` 置换成 `JUHE_CONFIG["api_key"]` 即可。
(以上操作完成后要重启rails s才会生效)
要注意：
```
* YAML 格式使用空白缩排来表达资料的阶层关系，请务必缩排整齐
* YAML 格式会区分数字和字串，例如 01234 会看成 1234，如果要确保被解析成字串，请加上引号，例如"01234"
* 读出来的 Hash 是用字串 key，不是 symbol key。是 JUHE_CONFIG["api_key"]而不是 JUHE_CONFIG[:api_key]
接着我们要告诉 Git 不要 commit 这个档案，这样就不用担心 git push 会把 api key 洩漏出去。
```
编辑 .gitignore，插入一行
```.gitignore
config/juhe.yml
```

依照惯例，你可以复制一个 juhe.yml.example 档案放进版本控制系统里面，这可以给你同事当作范例参考，内容例如：
```config/juhe.yml.example
development:
  api_key:"<juheapikey>"
```

## 3.建立API服务器

### 3-1 目标

要实作一个订票系统 API 服务器，可以提供给手机 iOS, Android 应用程式，或是一个开放平台给别的开发者串接使用。
功能包括：
```
* 可以查询有哪些列车
* 可以查询特定列车有哪些空位
* 可以订票，并得到一组订票号码(乱数产生)
* 根据订票号码，可以查询订票资料
* 根据订票号码，可以修改订票资料
* 根据订票号码，可以取消订票
```
Models 会有 Train 和 Reservation。

根据上述的需求，我们需要设计对应的 Web API，首先需要决定网址和 HTTP 方法：
```
* GET /trains
* GET /trains/{列车编号}
* POST /reservations/{订票号码}
* GET /reservations/{订票号码}
* PATCH /reservations/{订票号码}
* DELETE /reservations/{订票号码}
```

### 3-2 什么是 REST API

在 Rails 的路由中，我们已经学过 RESTful 的概念：
```
* GET 读取资料
* POST 新增资料
* PATCH 修改资料
* DELETE 删除资料
```
在设计Web API 的时候，我们也是用一样的大原则进行设计，这种设计原则就叫做REST：围绕在Model(在REST中叫做Resource 资源)来建构CRUD 的操作，其中网址会是名词，用不同的HTTP 方法来区分CRUD 操作。
不过，有时候有些操作也不完全是 CRUD 的概念，例如批次更新的操作，可能就会设计成
POST `/topics/bulk_update`
这种风格叫做 RPC(remote procedure call: 远端程序呼叫)，网址是动词，POST 表示呼叫。
又例如订阅可以有两种设计风格，第一种是 REST 风格，
POST `/topics/{topic_id}/subscription` 和 DELETE `/topics/{topic_id}/subscription/{id}`
其中 subscription 是名词，用 POST 表示新增、用 DELETE 表示删除。
或第二种 RPC (remote procedure call: 远端程序呼叫) 风格：
POST `/topics/{topic_id}/subscribe` 和 POST `/topics/{topic_id}/unsubscribe`
subscribe 和 unsubscribe 是动词，用 POST 表示执行。
RPC 风格也是常见的设计，目前设计 Web API 的主流是以 REST 风格为主。但无论是 REST 或 RPC 风格，切记 HTTP GET 和 POST 方法不能用错：GET 只能单纯读取资料，不应该修改资料。而 POST 则是执行某个操作，会修改到服务器的资料。
这是因为互联网都会假设 GET 是可以重复读取并缓存的，而 POST 不行。因此搜寻引擎只会用 GET 抓资料，像这篇文章就闹了笑话，这个人用 GET 来删除资料，造成Google 爬虫一爬就不小心删除了，他还以为是 Google 故意骇他...lol 另外，像浏览器的表单送出是用POST，如果我们在action 中不redirect (也就是让浏览器去GET 另一页)，而是直接render 返回，那么如果用户重新整理画面的话，浏览器会跳出以下的警告视窗，要求用户确认是否再POST 一次，因为这可能会造成重复操作(重复新增)。如果是 GET 的话，重新整理就不会有这种警告了。

### 3-3 建立 Models

执行 `rails g model train`
修改 `db/migrate/201703XXXXXXXX_create_trains.rb`
```db/migrate/201703XXXXXXXX_create_trains.rb
 class CreateTrains < ActiveRecord::Migration[5.0]
   def change
     create_table :trains do |t|
+      t.string :number, :index => true # 列车号码
       t.timestamps
     end
   end
 end
```

执行 `rails g model reservation`
修改 `db/migrate/201703XXXXXXXX_create_reservations.rb`
```db/migrate/201703XXXXXXXX_create_reservations.rb
 class CreateReservations < ActiveRecord::Migration[5.0]
   def change
     create_table :reservations do |t|
+      t.string :booking_code, :index => true # 订票号码，订好票之后有这个号码修改或者取消订票
+      t.integer :train_id, :index => true
+      t.string :seat_number, :index => true # 座位号码
+      t.integer :user_id, :index => true
+      t.string :customer_name
+      t.string :customer_phone
       t.timestamps
     end
   end
 end
```

执行 `rake db:migrate` 建立数据表。
修改 `app/models/train.rb` 加上关联和资料验证，以及一个 `available_seats` 方法回传可以被预订的座位号码：
```app/models/train.rb
   class Train < ApplicationRecord
+    validates_presence_of :number
+    has_many :reservations
+
+    def available_seats
+      # TODO: 回传有空的座位，这里先暂时固定回传一个数组，等会再来处理
+      ["1A", "1B", "1C", "1D", "1F"]
+    end
   end
```

以及修改 app/models/reservation.rb 针对每笔 Reservation 在新建的时候，随机数产生一个 `booking_code` 这是订票号码，订好票之后，可以用这个号码来做修改或取消订票：
```app/models/reservation.rb
 class Reservation < ApplicationRecord
+  validates_presence_of :train_id, :seat_number, :booking_code
+  validates_uniqueness_of :seat_number, :scope => :train_id
+
+  belongs_to :train
+
+  before_validation :generate_booking_code, :on => :create
+
+  def generate_booking_code
+    self.booking_code = SecureRandom.uuid
+  end
 end
```

编辑 db/seeds.rb 加入种子资料：
```db/seeds.rb
Train.create!( :number => "0822")
Train.create!( :number => "0603")
Train.create!( :number => "0826")
Train.create!( :number => "0642")
```

执行 `rake db:seed` 就有这些种子列车资料了。

### 3-4 配置路由

根据上述的 API 设计，我们来设置 config/routes.rb：
```config/routes.rb
 Rails.application.routes.draw do
+ namespace :api, :defaults => { :format => :json } do
+   namespace :v1 do
+     get "/trains"  => "trains#index", :as => :trains
+     get "/trains/:train_number" => "trains#show", :as => :train
+
+     get "/reservations/:booking_code" => "reservations#show", :as => :reservation
+     post "/reservations" => "reservations#create", :as => :create_reservations
+     patch "/reservations/:booking_code" => "reservations#update", :as => :update_reservation
+     delete "/reservations/:booking_code" => "reservations#destroy", :as => :cancel_reservation
+   end
+ end

 # (略)
 end
```

其中两层的namespace 会让网址前增加`/api/v1/`、Controller 的目录多两层放在`app/controllers/api/v1/` 下、Controller 类的名字前面增加Api::V1，变成Api::V1::ReservationsController、路由方法变成`api_v1_XXXXX_path` 和`api_v1_XXXXX_url`
而其中`post "/reservations" => "reservations#create", :as => :create_reservations`的意思是
客户端送出 POST /api/v1/reservations 时，会进入 Api::V1::ReservationsController 的 create 方法，而 as 参数的意思是产生这个地址的路由方法叫做 api_v1_create_reservations_path。
最后，`:defaults => { :format => :json }` 意思是默认客户端要求的是 JSON 格式，本来的默认值是 HTML。如果没有改这个的话，你必须在网址最后面加上 .json 来指定客户端要求的格式，例如 GET `/api/v1/trains.json`。

### 3-5 产生 Api controller

接着来制作 Controller，首先产生 ApiController。在 Terminal 输入：

`rails g controller api --no-assets`

修改 api_controller.rb

```app/controllers/api_controller.rb
- class ApiController < ApplicationController
+ class ApiController < ActionController::Base
end
```

我们会把 API 用途的 controller 都继承自 ApiController，而不是ApplicationController。这是因为 API 不需要 `protect_from_forgery with: :exception` 这一行的 CSRF 浏览器安全检查。

### 3-6 实作 GET /trains

执行

`rails g controller api::v1::trains --no-assets`

编辑 app/controllers/api/v1/trains_controller.rb
```app/controllers/api/v1/trains_controller.rb
- class Api::V1::TrainsController < ApplicationController
+ class Api::V1::TrainsController < ApiController

+  def index
+    @trains = Train.all
+    render :json => {
+      :data => @trains.map{ |train|
+        { :number => train.number,
+            :train_url => api_v1_train_url(train.number)
+        }
+      }
+    }
+  end
+
+  def show
+    @train = Train.find_by_number!( params[:train_number] )
+
+    render :json => {
+      :number => @train.number,
+      :available_seats => @train.available_seats
+    }
+  end

 end
```

其中 render :json => 某个变量 的语法，会把变量转成 JSON 字串输出。这里也不需要准备 View .erb 档案。
因为这两个 API 都是用 HTTP GET 读取，我们可以直接打开浏览器，浏览 http://localhost:3000/api/v1/trains 就是用 GET 读取资料。


请先装 Chrome extension JSON Formatter，就会有排版整齐的输出。

浏览其中一笔列车的话 http://localhost:3000/api/v1/trains/0822

你也可以用 Postman 来看：


如果程序出错的话，在Postman会看到HTML原始码，反而很难看出错误的地方，这个时候可以再点 Preview 就能看到错误网页，或者是回到 Terminal 看服务器的log。

### 3-7 实作 reservations 定位

接下来实作订位：
执行 rails g controller api::v1::reservations --no-assets
编辑 app/controller/api/v1/reservations_controller.rb
```app/controller/api/v1/reservations_controller.rb
- class Api::V1::ReservationsController < ApplicationController
+ class Api::V1::ReservationsController < ApiController

+  def create
+    @train = Train.find_by_number!( params[:train_number] )
+    @reservation = Reservation.new( :train_id => @train.id,
+                                    :seat_number => params[:seat_number],
+                                    :customer_name => params[:customer_name],
+                                    :customer_phone => params[:customer_phone] )
+
+    if @reservation.save
+      render :json => { :booking_code => @reservation.booking_code,
+                        :reservation_url => api_v1_reservation_url(@reservation.booking_code) }
+    else
+      render :json => { :message => "订票失败", :errors => @reservation.errors }, :status => 400
+    end
+  end

end
```

这样就完成了，要怎么测试呢? 如果直接浏览 http://localhost:3000/api/v1/reservations 的话，浏览器会用 GET 而不是 POST，这时候必须用 Postman 的表单进行测试，输入网址，方法选 POST，在 Body 中输入参数，按下送出之后，得到下面的结果就表示完成了：


### 3-8 完成其他部分

接下来让我们在 Api::V1::ReservationsController 完成其他 API：
查询

```app/controllers/api/v1/reservations_controller.rb
+ def show
+   @reservation = Reservation.find_by_booking_code!( params[:booking_code] )
+
+   render :json => {
+     :booking_code => @reservation.booking_code,
+     :train_number => @reservation.train.number,
+     :seat_number => @reservation.seat_number,
+     :customer_name => @reservation.customer_name,
+     :customer_phone => @reservation.customer_phone
+   }
+ end
```
用 Postman 测试，用 GET `http://localhost:3000/api/v1/reservations/`订票号码

修改
```app/controllers/api/v1/reservations_controller.rb
+ def update
+   @reservation = Reservation.find_by_booking_code!( params[:booking_code] )
+   @reservation.update( :customer_name => params[:customer_name],
+                        :customer_phone => params[:customer_phone] )

+   render :json => { :message => "更新成功" }
+ end
```

用 Postman 测试，用 PATCH `http://localhost:3000/api/v1/reservations/`订票号码

取消
```app/controllers/api/v1/reservations_controller.rb
+ def destroy
+   @reservation = Reservation.find_by_booking_code!( params[:booking_code] )
+   @reservation.destroy

+   render :json => { :message => "已取消定位" }
+ end
```

用 Postman 测试，用 DELETE `http://localhost:3000/api/v1/reservations/`订票号码

完成 Train#availale_seats 方法

在前述步骤中的 Train#available_seats 让我们完成它：
```app/models/train.rb
 class Train < ApplicationRecord

   validates_presence_of :number
   has_many :reservations

+  # 产生所有位置从 1A~6C
+  # ["1A", "1B", "1C", "2A", "2B", "2C", "3A", "3B", "3C",
+  #  "4A", "4B", "4C", "5A", "5B", "5C", "6A", "6B", "6C"]
+  SEATS = begin
+    (1..6).to_a.map do |series|
+      ["A","B","C"].map do |letter|
+       "#{series}#{letter}"
+      end
+    end
+  end.flatten

   def available_seats
-    # TODO: 回传有空的座位，这里先暂时固定回传一个数组，等会再来处理
-    ["1A", "1B", "1C", "1D", "1F"]

+    # 所有 SEATS 扣掉已经订位的资料
+    return SEATS - self.reservations.pluck(:seat_number)
   end

 end
```

### 3-9 解说

以下补充说明设计的缘由：
HTTP response code

HTTP 的 response 都会有一个 HTTP 状态码，最基本常见会用到的有：
```
* 200 成功(这是默认值)
* 400 客户端参数错误，例如资料验证失败，必填的资料没有填等等
* 401 Unauthorized 要求登入
* 403 有登入但是权限不够
* 404 找无此资源
* 500 服务器错误
例如我们在订位失败的时候，多指定了 :status => 400
拆开 URL 和 controller
```
在路由中我们使用了 namespace :api 和 namespace :v1，让 API 使用的 controller，和网页用户的 controller 拆开，网址用 api/v1 也表示这是 API 专用的版本。
原因是
1. API 的操作流程，和网页用户的操作流程是迥异的，拆开来有助于维护
2. api/v1 是因为需要保持向下相容性。我们不能随意变更 API 格式，不然客户端的程序会坏掉。不像 Web 程式可以随时升级，行动装置的 App 上架需要时间，因此需要保持 API 的向下相容性。
怎样叫做破坏向下相容的变更呢? 例如修改网址、修改 JSON key 的名称、变更 value 的型态等等。如果只是新增 key 是相容的。也因此不是每次有改 API 一定都需要递增版本。只有破坏性的变更才需要改成 v2。
router.rb 写法

我们也可以改用大家原本熟悉的 resources 写法：
```
namespace :api, :defaults => { :format => :json } do
  namespace :v1 do
    resources :trains, :only => [:index, :show]
    resources :reservations, :only => [:show, :create, :update, :destroy]        
  end
end
```
不过，resources 写法是 Rails 独有的，因此在撰写 API 说明文件的时候，我们会逐条每个 API 都列出来，这样跟我们合作的 iOS 、Android 工程师或第三方工程师才看得懂怎么呼叫 Web API。

## 4.实作认证API

### 4-1 目标

上一章的 API 操作都不需要任何认证，接下来我们想要多加一个功能来示范需要认证的情况：
* 使用者可以在网页上注册、登入，拿到 API Key
* 如果在有登入的情况下进行订票的话，则可以查询该用户下的所有订票
本章会实作的 API 是查询该用户的所有订票：
GET /api/v1/reservations

### 4-2 装 Devise 产生 User Model

编辑 Gemfile 加上 `gem "devise"`
执行 `bundle`，然后重启服务器
执行 `rails g devise:install`
执行 `rails g devise user`
执行 `rake db:migrate`
执行 `rails g controller welcome`
新增 app/views/welcome/index.html.erb 档案
```app/views/welcome/index.html.erb
  <h2>订票系统</h2>
```

编辑 routes.rb，插入一行：
```
config/routes.rb
+   root "welcome#index"
```
编辑 `app/views/layout/application.html.erb`，插入：
```app/views/layout/application.html.erb
 <body>
+  <% if current_user %>
+     <%= link_to('登出', destroy_user_session_path, :method => :delete) %>
+    <%= link_to('修改密码', edit_registration_path(:user)) %>
+  <% else %>
+    <%= link_to('注册', new_registration_path(:user)) %> |
+    <%= link_to('登入', new_session_path(:user)) %>
+   <% end %>

...(略)
```
编辑 `app/models/user.rb`，加上 `reservations` 关联
```app/models/user.rb
 class User < ApplicationRecord

+ has_many :reservations

...(略)
```
编辑 `app/models/reservation.rb`，加上 `user` 关联
```app/models/reservation.rb
 class Reservation < ApplicationRecord

+ belongs_to :user, :optional => true

...(略)
```
### 4-3 产生 API 用的 token

我们在第二章使用天气 API 时，会用到 api key 来做凭证。这里我们也想要一样的机制。首先会新增一个字段 authentication_token 字段(这里命名成 token，跟 API Key 是一样意思)，并且乱数产生一个凭证：
执行 `rails g migration add_token_to_users`
修改这个 migration，内容如下
```201703XXXXXXXX_add_token_to_users.rb
 class AddTokenToUsers < ActiveRecord::Migration
   def change
+    add_column :users, :authentication_token, :string
+    add_index :users, :authentication_token, :unique => true
+
+    User.find_each do |u|
+      puts "generate user #{u.id} token"
+      u.generate_authentication_token
+      u.save!
+    end
   end
 end
```

修改 `app/models/user.rb` 加上 `generate_authentication_token` 方法：
```app/models/user.rb
  class User < ApplicationRecord

+   before_create :generate_authentication_token
+
+   def generate_authentication_token
+     self.authentication_token = Devise.friendly_token
+   end

  ...(略)
  end
```

然后执行 `rake db:migrate`
编辑 `app/views/welcome/index.html.erb`
```app/views/welcome/index.html.erb
   <h2>订票系统</h2>

+  <% if current_user %>
+    <p>已经登入：你的 API token 是 <code><%= current_user.authentication_token  %></code></p>
+  <% else %>
+    <p>尚未登入</p>
+  <% end %>
```

浏览 `http://localhost:3000` 并注册一个帐号，就可以在画面上看到该用户的 API token 了。

### 4-4 设置 current_user

接着我们在 ApiController 上实作 before_action :authenticate_user_from_token! 方法，如果客户端的 HTTP request 请求有带 auth_token 参数的话，就会进行登入(但这里没有强制一定要登入)：
```app/controllers/api_controller.rb
 class ApiController < ActionController::Base

+  before_action :authenticate_user_from_token!
+
+  def authenticate_user_from_token!
+
+    if params[:auth_token].present?
+      user = User.find_by_authentication_token( params[:auth_token] )
+
+      # sign_in 是 Devise 的方法，会设定好 current_user
+      sign_in(user, store: false) if user
+    end
+  end

 end
```

只要呼叫 API 的时候，有多带 auth_token，就会设定好 current_user
4-5 修改订票 API

修改 app/controller/api/v1/reservations_controller.rb 的 create 方法，插入一行 @reservation.user = current_user
```app/controller/api/v1/reservations_controller.rb
 def create
   @train = Train.find_by_number!( params[:train_number] )
   @reservation = Reservation.new( :train_id => @train.id,
                                   :seat_number => params[:seat_number],
                                   :customer_name => params[:customer_name],
                                   :customer_phone => params[:customer_ phone] )

+  @reservation.user = current_user

   if @reservation.save
     render :json => { :booking_code => @reservation.booking_code,
                       :reservation_url =>  api_v1_reservation_url(@reservation.booking_code) }
   else
     render :json => { :message => "订票失败", :errors => @reservation.errors  }, :status => 400
   end
 end
```

这样如果是登入的情况，这张定票就会关联到该用户。
4-6 可以查询所有我的订票

修改 config/routes.rb
```config/routes.rb
 namespace :api, :defaults => { :format => :json } do
   namespace :v1 do
+     get "/reservations" => "reservations#index", :as => :reservations
     # ...(略)
```

修改 app/controller/api/v1/reservations_controller.rb，新增 index 方法：
```app/controller/api/v1/reservations_controller.rb
 class Api::V1::ReservationsController < ApiController

+  before_action :authenticate_user!, :only => [:index] # 这会检查 index +这个操作一定要登入
+
+  def index
+    @reservations = current_user.reservations
+
+    render :json => {
+      :data => @reservations.map { |reservation|
+        {
+          :booking_code => reservation.booking_code,
+          :train_number => reservation.train.number,
+          :seat_number => reservation.seat_number,
+          :customer_name => reservation.customer_name,
+          :customer_phone => reservation.customer_phone
+        }
+      }
+    }
+  end

  # ...(略)
 end
```

用 Postman 进行测试，首先新增订票，记得多传 auth_token 参数表示这是登入的用户：

接着查询

GET 方法是没有 HTTP Body 的，它的参数会直接接在网址后面。

4-7 解说

对 API 客户端来说，所有需要登入的操作，都必须带入 auth_token 这个参数，这样服务器才能识别是哪一个使用者。你可能会觉得为什么需要这样的 api key 的机制，每个用户不是已经有帐号密码了吗? 为什么不能每个操作干脆带着帐号密码参数即可?
这是因为用 api key 的机制，我们可以：
* 安全性，乱数产生的强度比密码高，甚至可以设计有效时间
* 独立性，使用者改密码不会影响 api key，这样客户端就不需要重新设定过

## 5.实作注册、登录、登出API

### 5-1 目标

上一章中是直接在网页上看到 auth_token 让用户使用，但这个前提是用户本身就是开发者，就像第一章我们使用数据聚合一样，我们直接在后台就看到了 api key。
另一种常见情境是我们自己开发客户端 App，例如 iOS 或 Android，这时候就不能让小白用户自己去网页上复制贴上 api key 了。这时候我们就得做登入的 API，好让用户输入帐号密码登入，拿到 API Key 存在客户端 App 上来使用。
这一章我们将实作以下 API，包括注册、登入和登出：
POST /api/v1/signup
POST /api/v1/login
POST /api/v1/logout

### 5-2 实作 AuthController

编辑 config/routes.rb 加上路由：
```config/routes.rb
 namespace :api, :defaults => { :format => :json } do
   namespace :v1 do

+    post "/signup" => "auth#signup"
+    post "/login" => "auth#login"
+    post "/logout" => "auth#logout"

     # ...(略)
   end
 end
```

输入 rails g controller api::v1::auth --no-assets 产生 controller，编辑它：
```app/controllers/api/v1/auth_controller.rb
- class Api::V1::AuthController < ApplicationController
+ class Api::V1::AuthController < ApiController

+   before_action :authenticate_user!, :only => [:logout]
+
+   def signup
+     user = User.new( :email => params[:email], :password => params[:password] )
+
+     if user.save
+       render :json => { :user_id => user.id }
+     else
+       render :json => { :message => "Failed", :errors => user.errors }, :status => 400
+     end
+   end
+
+   def login
+     if params[:email] && params[:password]
+       user = User.find_by_email( params[:email] )
+     end
+
+     if user && user.valid_password?( params[:password] )
+       render :json => { :message => "Ok",
+                         :auth_token => user.authentication_token,
+                         :user_id => user.id }
+     else
+       render :json => { :message => "Email or Password is wrong" }, :status => 401
+     end
+   end
+
+   def logout
+     current_user.generate_authentication_token # 重新产生一组，本来的 token 就失效了
+     current_user.save!
+
+     render :json => { :message => "Ok"}
+   end
+
end
```

记得改继承自 ApiController，不然 POST 时会有 ActionController::InvalidAuthenticityToken 的错误
用 Postman 进行测试，首先是注册 POST /api/v1/signup：

接着登入 POST /api/v1/login，客户端用帐号密码，来换得 auth_token

最后是登出 POST /api/v1/logout

### 5-3 解说

这两章比较繁琐一点，但是同学们不需要担心写不出来，因为没有任何两年内新手可以自己写出认证 API，一定都是抄的，例如抄 `https://github.com/plataformatec/devise/wiki/How-To:-Simple-Token-Authentication-Example` 反正也只会做一次，而且都长一样，各位同学不用担心。

## 6.实作用户更新资料 API

### 6-1 目标

这一章我们实作两个有关用户的 API：
* PATCH /me 更新自己的资料，包括修改 E-mail、密码和上传照片
* GET /me 查询自己的资料
目的是处理档案上传的情况。

### 6-2 修改个人资料(照片档案上传)

修改 Gemfile，加上
```Gemfile
# ...(略)

+  gem 'carrierwave'
+  gem 'mini_magick'
```

执行 bundle 然后重启服务器
执行 rails g uploader avatar

执行 rails g migration add_avatar_to_users avatar:string

执行 rake db:migrate
编辑 app/uploaders/avatar_uploader.rb 增加不同缩图的情况：
```app/uploaders/avatar_uploader.rb
  class AvatarUploader < CarrierWave::Uploader::Base
+
+   include CarrierWave::MiniMagick
+
    storage :file
+
+   process resize_to_fit: [800, 800]
+
+   version :thumb do
+     process resize_to_fill: [200,200]
+   end
+
+   version :medium do
+     process resize_to_fill: [400,400]
+   end
+
    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

  end
```

编辑 app/models/user.rb，新增一行：
```app/models/user.rb
+   mount_uploader :avatar, AvatarUploader

编辑 config/routes.rb，加入
config/routes.rb
 namespace :api, :defaults => { :format => :json } do
   namespace :v1 do

+    get "/me" => "users#show", :as => :user
+    patch "/me" => "users#update", :as => :update_user
     # ...(略)
```

执行 rails g controller api::v1::users --no-assets
编辑 app/controllers/api/v1/users_controller.rb
```app/controllers/api/v1/users_controller.rb
- class Api::V1::UsersController < ApplicationController
+ class Api::V1::UsersController < ApiController

+   before_action :authenticate_user!
+
+   def update
+     if current_user.update(user_params)
+       render :json => { :message => "OK" }
+     else
+       render :json => { :message => "Failed", :errors => current_user.errors }, :status => 400
+     end
+   end
+
+   protected
+
+   def user_params
+     params.permit(:email, :password, :avatar)
+   end
  end
```

用 Postman 上传照片看看

注意到 Postman 选用 POST 时，还可以选 request 的资料格式。虽然我们讲 Web API 常用 JSON 格式，但这只是说 response 的资料格式用 JSON。客户端的 HTTP request 资料格式不一定是 JSON。而 request 也是有不同种资料格式，其中只有 form-data 才能上传档案。详细的原理可以参考 四种常见的 POST 提交数据方式

### 6-3 查询个人资料

编辑 /api/v1/users_controller.rb
```app/controllers/api/v1/users_controller.rb
  # ...(略)

+ def show
+   render :json => {
+     :email => current_user.email,
+     :avatar => current_user.avatar,
+     :updated_at => current_user.updated_at,
+     :created_at => current_user.created_at
+   }
+ end
```

浏览器浏览 `http://localhost:3000/api/v1/me?auth_token=FYN27sLKKCNt4LhTH5or`

## 7. Jbuilder 用法

### 7-1 前言

通常在 Web API 中，这几个 POST/PATCH/DELETE 操作的回传值都很简单，我们可以在 controller 里面用 render :json 就解决了。但是 GET 拿资料可能会很复杂，因为资料字段很多。这里介绍使用 JBuilder 来定义 JSON 格式的作法，这是一个 Rails 默认就安装的 gem，你可以在 Gemfile中看到它。

### 7-2 修改 train API

新增 `app/views/api/v1/trains/show.json.jbuilder` 档案，这就是 JBuilder 样板，用来定义 JSON 长什么样子：
```app/views/api/v1/trains/show.json.jbuilder
json.number @train.number
json.available_seats @train.available_seats
json.created_at @train.created_at
```

修改 app/controllers/api/v1/trains_controller.rb，拿掉 render :json 的部分：
```app/controllers/api/v1/trains_controller.rb
 def show
   @train = Train.find_by_number!( params[:train_number] )

-    render :json => {
-      :number => @train.number,
-      :available_seats => @train.available_seats
-    }
 end
```

用浏览器浏览 `http://localhost:3000/api/v1/trains/0822` 确认正常。

### 7-3 修改 trains API 输出 array 资料

新增 app/views/api/v1/trains/index.json.jbuilder
```app/views/api/v1/trains/index.json.jbuilder
json.data do
  json.array! @trains do |train|
    json.number train.number
    json.train_url api_v1_train_url(train.number)
  end
end
```

修改 app/controllers/api/v1/trains_controller.rb，拿掉 render :json 的部分：
```app/controllers/api/v1/trains_controller.rb
   def index
     @trains = Train.all
-    render :json => {
-      :data => @trains.map{ |train|
-        { :number => train.number,
-            :train_url => api_v1_train_url(train.number)
-        }
-      }
-    }
   end
```

用浏览器浏览 `http://localhost:3000/api/v1/trains` 确认正常。

### 7-4 可以使用 partial 样板

我们发现上述的 index.json.jbuilder 和 show.json.jbuilder 非常相像，因为都是描述 train，这时候我们可以来使用 partial 样板的功能。
新增 `app/views/api/v1/trains/_item.json.jbuilder`
```app/views/api/v1/trains/_item.json.jbuilder
json.number train.number
json.available_seats train.available_seats
json.created_at train.created_at
```

修改 app/views/api/v1/trains/show.json.jbuilder
```app/views/api/v1/trains/show.json.jbuilder
- json.number @train.number
- json.available_seats @train.available_seats
- json.created_at @train.created_at

+ json.partial! 'item', train: @train
```

修改 app/views/api/v1/trains/index.json.jbuilder
```app/views/api/v1/trains/index.json.jbuilder
 json.data do
-  json.array! @trains do |train|
-    json.number train.number
-    json.train_url api_v1_train_url(train.number)
-  end

+  json.array! @trains, :partial => "item", :as => :train

 end
```

用浏览器浏览 `http://localhost:3000/api/v1/trains` 和 `http://localhost:3000/api/v1/trains/0822` 依旧正常。

### 7-5 输出分页资料

GET /api/v1/trains 这个 API 我们并没有做分页，如果资料量很多的话，会需要一个分页的机制，不然客户端会一次下载太多资料。
首先让我们加上分页的 Gem，请修改 Gemfile
```Gemfile
   # ...(略)
+  gem 'will_paginate'
```

执行 `bundle` 然后重启服务器。
修改 app/controllers/api/v1/trains_controller.rb
```app/controllers/api/v1/trains_controller.rb
  def index
-   @trains = Train.all
+   @trains = Train.paginate( :page => params[:page] )
  end
```

修改 app/views/api/v1/trains/index.json.jbuilder
```app/views/api/v1/trains/index.json.jbuilder
+ json.meta do
+   json.current_page @trains.current_page
+   json.total_pages @trains.total_pages
+   json.per_page @trains.per_page
+   json.total_entries @trains.total_entries

+   if @trains.current_page == @trains.total_pages
+     json.next_url nil # 最后一页就没有下一页了
+   else
+     json.next_url api_v1_trains_url( :page => @trains.next_page )
+   end

+   if @trains.current_page == 1
+     json.previous_url nil # 第一页就没有上一页
+   else
+     json.previous_url api_v1_trains_url( :page => @trains.previous_page )
+   end
+ end

json.data do
  json.array! @trains, :partial => "item", :as => :train
end
```

这里新增了一个 meta 哈希，来描述总共有多少页、多少笔、下一页、上一页等等资讯。
因为列车资料不够多，我们可以进 rails c 输入 `100.times { |i| Train.create( :number => "T#{i}" ) }` 就会产生一百笔资料。

继续浏览 `http://localhost:3000/api/v1/trains?page=2` 就会到第二页。

### 7-6 新增 Train Logo 图片

在继续下一节之前，我们希望 train 能有 Logo 图片
执行 `rails g uploader train_logo`
执行 `rails g migration add_train_logo_to_trains train_logo:string`
执行 `rake db:migrate`
编辑 app/models/train.rb，插入一行：
```app/models/train.rb
# ...(略)
+   mount_uploader :train_logo, TrainLogoUploader
```

因为现有的 train 资料并没有图片，我们可以进 rails console，然后执行
```
t = Train.first
t.train_logo = open("https://ihower.tw/ruby.jpg")
# 或是你本机电脑上的一张图片 t.train_logo = open("/Users/your_username/Pictures/your_image.png")
t.save
```
就会存一张图片了。
编辑 app/views/api/v1/trains/item.json.jbuilder

加入图片资讯：
```app/views/api/v1/trains/_item.json.jbuilder
  json.number train.number

+ if train.train_logo.present?
+   json.logo_url asset_url( train.train_logo.url )
+   json.logo_file_size train.train_logo.size
+   json.logo_content_type train.train_logo.content_type
+ else
+   json.logo_url nil
+   json.logo_file_size nil
+   json.logo_content_type nil
+ end

 json.available_seats train.available_seats
 json.created_at train.created_at
```

浏览 `http://localhost:3000/api/v1/trains` 会得到：

### 7-7 修改 reservations API

延续上一节，假设客户端手机App上我的订票页面，除了显示我的订票之外，也想要显示 train 的 logo。那么根据目前的 Web API 设计，会需要发送多个 HTTP request 请求才能显示 train 图片，例如：
```
GET /api/v1/reserveations   # 假设拿到三张票分别是 0822, 0606, 0826
GET /api/v1/train/0822      # 拿 train logo
GET /api/v1/train/0606      # 拿 train logo
GET /api/v1/train/0826      # 拿 train logo
```
手机的网络速度是不快的，每多发送一次请求，就很耗时间。因此我们会希望减少需要请求的次数。因此我们要修改 GET /api/v1/reservations 的回传 JSON，顺便回传完整 train 资料就好了：
修改 app/controllers/api/v1/reservations_controller.rb，把 render :json 拆除
```app/controllers/api/v1/reservations_controller.rb
   def index
     @reservations = current_user.reservations

-    render :json => {
-      :data => @reservations.map { |reservation|
-        {
-          :booking_code => reservation.booking_code,
-          :train_number => reservation.train.number,
-          :seat_number => reservation.seat_number,
-          :customer_name => reservation.customer_name,
-          :customer_phone => reservation.customer_phone
-        }
-      }
-    }

   end

  def show
    @reservation = Reservation.find_by_booking_code!( params[:booking_code] )

-   render :json => {
-     :booking_code => @reservation.booking_code,
-     :train_number => @reservation.train.number,
-     :seat_number => @reservation.seat_number,
-     :customer_name => @reservation.customer_name,
-     :customer_phone => @reservation.customer_phone
-   }
  end
```

新增 app/views/api/v1/reservations/item.json.jbuilder

```app/views/api/v1/reservations/_item.json.jbuilder
json.booking_code reservation.booking_code
json.train_number reservation.train.number
json.train do
  json.partial! 'api/v1/trains/item', train: reservation.train
end
json.seat_number reservation.seat_number
json.customer_name reservation.customer_name
json.customer_phone reservation.customer_phone
```

新增 app/views/api/v1/reservations/show.json.jbuilder

```app/views/api/v1/reservations/show.json.jbuilder
json.partial! 'item', reservation: @reservation
```

新增 app/views/api/v1/reservations/index.json.jbuilder

```app/views/api/v1/reservations/index.json.jbuilder
json.data do
  json.array! @reservations, :partial => "item", :as => :reservation
end
```

最后的结果会是：

这样客户端就只需要一个 request 就能拿到需要的资料了。
