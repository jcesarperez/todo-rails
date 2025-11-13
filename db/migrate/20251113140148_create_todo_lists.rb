class CreateTodoLists < ActiveRecord::Migration[7.1]
  def change
    create_table :todo_lists do |t|
      t.string :title, null: false
      t.timestamps
    end

    add_index :todo_lists, :title, unique: true
  end
end
