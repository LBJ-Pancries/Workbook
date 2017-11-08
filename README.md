#Rails101

###Add Bootstrap gem

  `git checkout -b Add_bootstrap_to_project`

  `subl .`

  Edit Gemfile

  ```
  gem 'bootstrap-sass'
  ```

  `bundle install`

  重开`rails s`

  Rename`mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss`

  修改app/assets/stylesheets/application.scss

  ```
  @import "bootstrap-sprockets";
  @import "bootstrap";
  ```

  保存（Save）

  `git add .`

  `git commit -m "add bootstrap to project"`

  ***
