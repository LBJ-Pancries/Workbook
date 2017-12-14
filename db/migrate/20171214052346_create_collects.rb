class CreateCollects < ActiveRecord::Migration[5.1]
  def change
    create_table :collects do |t|
      t.integer :post_id, :index => true
      t.integer :user_id, :index => true

      t.timestamps
    end
  end
end
