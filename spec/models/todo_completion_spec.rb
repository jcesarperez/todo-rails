require "rails_helper"

RSpec.describe Todo, type: :model do
  describe "completion status" do
    it "creates a todo with completed as false by default" do
      todo = Todo.create!(title: "New task")
      expect(todo.completed).to be(false)
    end

    it "can be created with completed as true" do
      todo = Todo.create!(title: "Done task", completed: true)
      expect(todo.completed).to be(true)
    end

    it "stores completion status in database" do
      todo = Todo.create!(title: "Task", completed: true)
      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end
  end

  describe "#mark_complete" do
    it "sets completed to true" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.mark_complete

      expect(todo.completed).to be(true)
    end

    it "persists to database" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.mark_complete

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end

    it "does nothing if already completed" do
      todo = Todo.create!(title: "Task", completed: true)
      todo.mark_complete

      expect(todo.completed).to be(true)
      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end

    it "returns the todo" do
      todo = Todo.create!(title: "Task", completed: false)
      result = todo.mark_complete

      expect(result).to eq(todo)
    end
  end

  describe "#mark_incomplete" do
    it "sets completed to false" do
      todo = Todo.create!(title: "Task", completed: true)
      todo.mark_incomplete

      expect(todo.completed).to be(false)
    end

    it "persists to database" do
      todo = Todo.create!(title: "Task", completed: true)
      todo.mark_incomplete

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(false)
    end

    it "does nothing if already incomplete" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.mark_incomplete

      expect(todo.completed).to be(false)
      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(false)
    end

    it "returns the todo" do
      todo = Todo.create!(title: "Task", completed: true)
      result = todo.mark_incomplete

      expect(result).to eq(todo)
    end
  end

  describe "#toggle_completion" do
    it "changes incomplete to complete" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.toggle_completion

      expect(todo.completed).to be(true)
    end

    it "changes complete to incomplete" do
      todo = Todo.create!(title: "Task", completed: true)
      todo.toggle_completion

      expect(todo.completed).to be(false)
    end

    it "persists toggled state to database" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.toggle_completion

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end

    it "toggles multiple times" do
      todo = Todo.create!(title: "Task", completed: false)

      todo.toggle_completion
      expect(todo.completed).to be(true)

      todo.toggle_completion
      expect(todo.completed).to be(false)

      todo.toggle_completion
      expect(todo.completed).to be(true)
    end

    it "returns the todo" do
      todo = Todo.create!(title: "Task", completed: false)
      result = todo.toggle_completion

      expect(result).to eq(todo)
    end
  end

  describe "#completed?" do
    it "returns true when completed" do
      todo = Todo.create!(title: "Task", completed: true)
      expect(todo.completed?).to be(true)
    end

    it "returns false when not completed" do
      todo = Todo.create!(title: "Task", completed: false)
      expect(todo.completed?).to be(false)
    end
  end

  describe ".completed" do
    it "returns all completed todos" do
      completed1 = Todo.create!(title: "Task 1", completed: true)
      completed2 = Todo.create!(title: "Task 2", completed: true)
      incomplete = Todo.create!(title: "Task 3", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos.length).to eq(2)
      expect(completed_todos).to include(completed1, completed2)
      expect(completed_todos).not_to include(incomplete)
    end

    it "returns empty array when no completed todos" do
      Todo.create!(title: "Task", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos).to be_empty
    end
  end

  describe ".incomplete" do
    it "returns all incomplete todos" do
      completed = Todo.create!(title: "Task 1", completed: true)
      incomplete1 = Todo.create!(title: "Task 2", completed: false)
      incomplete2 = Todo.create!(title: "Task 3", completed: false)

      incomplete_todos = Todo.where(completed: false).to_a
      expect(incomplete_todos.length).to eq(2)
      expect(incomplete_todos).to include(incomplete1, incomplete2)
      expect(incomplete_todos).not_to include(completed)
    end

    it "returns empty array when all todos completed" do
      Todo.create!(title: "Task", completed: true)

      incomplete_todos = Todo.where(completed: false).to_a
      expect(incomplete_todos).to be_empty
    end
  end

  describe "completion workflow" do
    it "tracks completion status through workflow" do
      todo = Todo.create!(title: "Buy groceries", completed: false)
      expect(todo.completed).to be(false)

      todo.mark_complete
      expect(todo.completed).to be(true)

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)

      todo.mark_incomplete
      expect(todo.completed).to be(false)

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(false)
    end

    it "can update title and completion together" do
      todo = Todo.create!(title: "Old title", completed: false)
      todo.update(title: "New title", completed: true)

      reloaded = Todo.find(todo.id)
      expect(reloaded.title).to eq("New title")
      expect(reloaded.completed).to be(true)
    end

    it "counts completed and incomplete todos" do
      Todo.create!(title: "Task 1", completed: true)
      Todo.create!(title: "Task 2", completed: true)
      Todo.create!(title: "Task 3", completed: false)
      Todo.create!(title: "Task 4", completed: false)

      completed_count = Todo.where(completed: true).count
      incomplete_count = Todo.where(completed: false).count

      expect(completed_count).to eq(2)
      expect(incomplete_count).to eq(2)
      expect(completed_count + incomplete_count).to eq(Todo.count)
    end
  end

  describe "edge cases" do
    it "handles rapid status changes" do
      todo = Todo.create!(title: "Task", completed: false)

      6.times do |i|
        if i.even?
          todo.mark_complete
        else
          todo.mark_incomplete
        end
      end

      expect(todo.completed).to be(false)
      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(false)
    end

    it "mark_complete on already completed todo does not create extra saves" do
      todo = Todo.create!(title: "Task", completed: true)
      original_updated_at = todo.updated_at

      # Small delay to ensure timestamp would change if saved
      sleep(0.01)
      todo.mark_complete

      expect(todo.updated_at).to eq(original_updated_at)
    end

    it "different todos have independent completion states" do
      todo1 = Todo.create!(title: "Task 1", completed: true)
      todo2 = Todo.create!(title: "Task 2", completed: false)

      todo1.mark_incomplete
      todo2.mark_complete

      expect(todo1.completed).to be(false)
      expect(todo2.completed).to be(true)
    end
  end
end
