require "rails_helper"

RSpec.describe "TodoList and Todo Interaction", type: :model do
  describe "creating todos in a list" do
    it "creates todos associated with a todo_list" do
      list = TodoList.create!(title: "Shopping")

      list.todos.create!(title: "Milk")
      list.todos.create!(title: "Bread")
      list.todos.create!(title: "Eggs")

      expect(list.todos.count).to eq(3)
      expect(list.todos.map(&:title)).to include("Milk", "Bread", "Eggs")
    end

    it "marks todos as completed in a list" do
      list = TodoList.create!(title: "Work")
      todo1 = list.todos.create!(title: "Task 1", completed: false)
      todo2 = list.todos.create!(title: "Task 2", completed: true)

      completed = list.todos.where(completed: true)
      expect(completed.count).to eq(1)
      expect(completed.first.title).to eq("Task 2")
    end

    it "gets incomplete todos in a list" do
      list = TodoList.create!(title: "Work")
      list.todos.create!(title: "Done", completed: true)
      list.todos.create!(title: "Pending 1", completed: false)
      list.todos.create!(title: "Pending 2", completed: false)

      pending = list.todos.where(completed: false)
      expect(pending.count).to eq(2)
    end
  end

  describe "deleting lists cascades to todos" do
    it "deletes all todos when list is deleted" do
      list = TodoList.create!(title: "Temporary")
      list.todos.create!(title: "Task 1")
      list.todos.create!(title: "Task 2")

      todo_ids = list.todos.pluck(:id)
      list.destroy

      expect(Todo.where(id: todo_ids)).to be_empty
    end
  end

  describe "todos can be independent or in lists" do
    it "has independent todos without a list" do
      todo = Todo.create!(title: "Standalone")
      expect(todo.todo_list).to be_nil
      expect(todo.todo_list_id).to be_nil
    end

    it "can query all todos with lists" do
      list = TodoList.create!(title: "List 1")
      list.todos.create!(title: "In list")
      Todo.create!(title: "Independent")

      todos_with_list = Todo.where.not(todo_list_id: nil)
      expect(todos_with_list.count).to eq(1)
    end

    it "can query all todos without lists" do
      list = TodoList.create!(title: "List 1")
      list.todos.create!(title: "In list")
      Todo.create!(title: "Independent")

      todos_without_list = Todo.where(todo_list_id: nil)
      expect(todos_without_list.count).to eq(1)
    end
  end
end
