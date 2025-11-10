require "rails_helper"

RSpec.describe Todo, type: :model do
  describe ".all" do
    it "returns all todos" do
      todo1 = Todo.create!(title: "Task 1")
      todo2 = Todo.create!(title: "Task 2")
      todo3 = Todo.create!(title: "Task 3")

      all_todos = Todo.all
      expect(all_todos.length).to eq(3)
      expect(all_todos).to include(todo1, todo2, todo3)
    end

    it "returns empty array when no todos exist" do
      todos = Todo.all
      expect(todos).to be_empty
    end
  end

  describe ".count" do
    it "returns the number of todos" do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")

      expect(Todo.count).to eq(2)
    end

    it "returns 0 when no todos exist" do
      expect(Todo.count).to eq(0)
    end
  end

  describe ".first and .last" do
    it "returns the first todo" do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")

      expect(Todo.first).to eq(todo1)
    end

    it "returns the last todo" do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")

      expect(Todo.last).to eq(todo2)
    end

    it "returns nil when no todos exist" do
      expect(Todo.first).to be_nil
      expect(Todo.last).to be_nil
    end
  end

  describe ".find" do
    it "finds a todo by id" do
      todo = Todo.create!(title: "Find me")
      found = Todo.find(todo.id)

      expect(found).to eq(todo)
    end

    it "raises RecordNotFound when todo does not exist" do
      expect {
        Todo.find(999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".find_by" do
    it "finds a todo by title" do
      todo = Todo.create!(title: "Specific Task")
      found = Todo.find_by(title: "Specific Task")

      expect(found).to eq(todo)
    end

    it "returns nil when no match found" do
      found = Todo.find_by(title: "Non-existent")

      expect(found).to be_nil
    end

    it "finds a todo by completed status" do
      completed_todo = Todo.create!(title: "Done", completed: true)
      incomplete_todo = Todo.create!(title: "Not done", completed: false)

      found = Todo.find_by(completed: true)
      expect(found).to eq(completed_todo)
    end
  end

  describe ".where" do
    it "returns todos matching a condition" do
      completed1 = Todo.create!(title: "Task 1", completed: true)
      completed2 = Todo.create!(title: "Task 2", completed: true)
      incomplete = Todo.create!(title: "Task 3", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos.length).to eq(2)
      expect(completed_todos).to include(completed1, completed2)
    end

    it "returns empty array when no matches found" do
      Todo.create!(title: "Task", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos).to be_empty
    end

    it "filters by multiple conditions" do
      todo1 = Todo.create!(title: "Buy milk", completed: true)
      todo2 = Todo.create!(title: "Buy milk", completed: false)
      todo3 = Todo.create!(title: "Walk dog", completed: true)

      results = Todo.where(title: "Buy milk", completed: true).to_a
      expect(results.length).to eq(1)
      expect(results.first).to eq(todo1)
    end
  end

  describe "ordering" do
    it "returns todos ordered by created_at ascending" do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")
      todo3 = Todo.create!(title: "Third")

      ordered = Todo.order(:created_at).to_a
      expect(ordered).to eq([todo1, todo2, todo3])
    end

    it "returns todos ordered by created_at descending" do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")
      todo3 = Todo.create!(title: "Third")

      ordered = Todo.order(created_at: :desc).to_a
      expect(ordered).to eq([todo3, todo2, todo1])
    end

    it "combines where and order" do
      incomplete1 = Todo.create!(title: "Task 1", completed: false)
      completed1 = Todo.create!(title: "Task 2", completed: true)
      incomplete2 = Todo.create!(title: "Task 3", completed: false)

      incomplete_ordered = Todo.where(completed: false).order(created_at: :desc).to_a
      expect(incomplete_ordered).to eq([incomplete2, incomplete1])
    end
  end
end
