# == Schema Information
#
# Table name: todo_lists
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_todo_lists_on_title  (title) UNIQUE
#
require "rails_helper"

RSpec.describe TodoList, type: :model do
  describe "validations" do
    subject { TodoList.new(title: "Test List") }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title) }
  end

  describe "associations" do
    it { is_expected.to have_many(:todos).dependent(:destroy) }
  end

  describe "attributes" do
    it "has a title" do
      todo_list = TodoList.new(title: "My List")
      expect(todo_list.title).to eq("My List")
    end

    it "has timestamps" do
      todo_list = TodoList.create!(title: "My List")
      expect(todo_list.id).not_to be_nil
      expect(todo_list.created_at).not_to be_nil
      expect(todo_list.updated_at).not_to be_nil
    end
  end

  describe ".create" do
    it "creates a new todo_list with valid title" do
      todo_list = TodoList.create(title: "Shopping List")
      expect(todo_list).to be_persisted
      expect(todo_list.title).to eq("Shopping List")
    end

    it "does not create without title" do
      todo_list = TodoList.create(title: "")
      expect(todo_list).not_to be_persisted
      expect(todo_list.errors.full_messages).to include("Title can't be blank")
    end

    it "does not create with duplicate title" do
      TodoList.create!(title: "My List")
      duplicate = TodoList.create(title: "My List")

      expect(duplicate).not_to be_persisted
      expect(duplicate.errors.full_messages).to include("Title has already been taken")
    end
  end

  describe "associations with todos" do
    let(:todo_list) { TodoList.create!(title: "My List") }

    it "can have multiple todos" do
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")
      todo3 = todo_list.todos.create!(title: "Task 3")

      expect(todo_list.todos.count).to eq(3)
      expect(todo_list.todos).to include(todo1, todo2, todo3)
    end

    it "destroys associated todos when destroyed" do
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")
      todo_ids = [todo1.id, todo2.id]

      todo_list.destroy

      expect(Todo.where(id: todo_ids)).to be_empty
    end

    it "todos belong to the todo_list" do
      todo = todo_list.todos.create!(title: "Task")
      expect(todo.todo_list).to eq(todo_list)
    end
  end

  describe "todo_lists queries" do
    it "returns all todo_lists" do
      list1 = TodoList.create!(title: "List 1")
      list2 = TodoList.create!(title: "List 2")

      all_lists = TodoList.all
      expect(all_lists.length).to eq(2)
      expect(all_lists).to include(list1, list2)
    end

    it "returns empty when no todo_lists" do
      expect(TodoList.all).to be_empty
    end

    it "finds todo_list by id" do
      todo_list = TodoList.create!(title: "My List")
      found = TodoList.find(todo_list.id)
      expect(found).to eq(todo_list)
    end

    it "finds todo_list by title" do
      todo_list = TodoList.create!(title: "Shopping")
      found = TodoList.find_by(title: "Shopping")
      expect(found).to eq(todo_list)
    end
  end

  describe "updating todo_list" do
    it "updates title" do
      todo_list = TodoList.create!(title: "Original")
      todo_list.update(title: "Updated")
      expect(todo_list.reload.title).to eq("Updated")
    end

    it "does not update to empty title" do
      todo_list = TodoList.create!(title: "Original")
      result = todo_list.update(title: "")
      expect(result).to be(false)
      expect(todo_list.reload.title).to eq("Original")
    end

    it "does not update to duplicate title" do
      list1 = TodoList.create!(title: "List 1")
      list2 = TodoList.create!(title: "List 2")

      result = list2.update(title: "List 1")
      expect(result).to be(false)
      expect(list2.reload.title).to eq("List 2")
    end
  end

  describe "deleting todo_list" do
    it "deletes a todo_list" do
      todo_list = TodoList.create!(title: "Delete me")
      todo_list_id = todo_list.id

      todo_list.destroy

      expect(TodoList.find_by(id: todo_list_id)).to be_nil
    end

    it "also deletes associated todos" do
      todo_list = TodoList.create!(title: "List")
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")

      todo_list.destroy

      expect(Todo.find_by(id: todo1.id)).to be_nil
      expect(Todo.find_by(id: todo2.id)).to be_nil
    end
  end

  describe "todo_list interactions" do
    it "maintains todos even if todo_list is updated" do
      todo_list = TodoList.create!(title: "Original")
      todo = todo_list.todos.create!(title: "Task")

      todo_list.update(title: "Updated")

      expect(todo.reload.todo_list_id).to eq(todo_list.id)
    end

    it "can move a todo to a different list" do
      list1 = TodoList.create!(title: "List 1")
      list2 = TodoList.create!(title: "List 2")
      todo = list1.todos.create!(title: "Task")

      todo.update(todo_list_id: list2.id)

      expect(list1.todos.count).to eq(0)
      expect(list2.todos.count).to eq(1)
      expect(todo.reload.todo_list).to eq(list2)
    end

    it "todos without list are independent" do
      todo = Todo.create!(title: "Independent task")
      expect(todo.todo_list).to be_nil
    end
  end
end
