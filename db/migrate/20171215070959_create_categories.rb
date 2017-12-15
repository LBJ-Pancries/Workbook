class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end

    add_column :posts, :category_id, :integer
    add_index :posts, :category_id
  end
end
