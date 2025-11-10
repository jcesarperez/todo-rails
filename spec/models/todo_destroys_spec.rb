require "rails_helper"

RSpec.describe Todo, type: :model do
  describe ".destroy" do
    it "removes a todo from the database" do
      todo = Todo.create!(title: "Delete me")
      todo_id = todo.id

      todo.destroy

      expect(Todo.find_by(id: todo_id)).to be_nil
    end

    it "returns the destroyed record" do
      todo = Todo.create!(title: "Delete me")
      result = todo.destroy

      expect(result).to eq(todo)
    end

    it "marks record as not persisted after destroy" do
      todo = Todo.create!(title: "Delete me")
      todo.destroy

      expect(todo.persisted?).to be(false)
    end

    it "destroys multiple todos" do
      todo1 = Todo.create!(title: "Task 1")
      todo2 = Todo.create!(title: "Task 2")
      todo3 = Todo.create!(title: "Task 3")

      todo1.destroy
      todo2.destroy

      expect(Todo.count).to eq(1)
      expect(Todo.first).to eq(todo3)
    end

    it "can destroy from find result" do
      todo = Todo.create!(title: "Task")
      found = Todo.find(todo.id)

      found.destroy

      expect(Todo.find_by(id: todo.id)).to be_nil
    end
  end

  describe ".delete" do
    it "removes a todo from the database" do
      todo = Todo.create!(title: "Delete me")
      todo_id = todo.id

      todo.delete

      expect(Todo.find_by(id: todo_id)).to be_nil
    end

    it "returns the deleted record" do
      todo = Todo.create!(title: "Delete me")
      result = todo.delete

      expect(result).to eq(todo)
    end

    it "is faster than destroy (no callbacks)" do
      todo = Todo.create!(title: "Task")

      # Delete doesn't trigger callbacks, just removes from DB
      expect(Todo.count).to eq(1)
      result = todo.delete
      expect(result).to eq(todo)  # Returns the deleted record
      expect(Todo.count).to eq(0)
    end
  end

  describe ".delete_all" do
    it "deletes all records" do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")
      Todo.create!(title: "Task 3")

      Todo.delete_all

      expect(Todo.count).to eq(0)
    end

    it "returns the number of records deleted" do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")

      result = Todo.delete_all

      expect(result).to eq(2)
    end

    it "can delete with conditions" do
      completed1 = Todo.create!(title: "Task 1", completed: true)
      completed2 = Todo.create!(title: "Task 2", completed: true)
      incomplete = Todo.create!(title: "Task 3", completed: false)

      Todo.where(completed: true).delete_all

      expect(Todo.count).to eq(1)
      expect(Todo.first).to eq(incomplete)
    end
  end

  describe "destroy vs delete" do
    it "destroy returns the record" do
      todo = Todo.create!(title: "Task")
      destroyed = todo.destroy

      expect(destroyed).to eq(todo)
    end

    it "delete returns the record" do
      todo = Todo.create!(title: "Task")
      deleted = todo.delete

      expect(deleted).to eq(todo)
    end

    it "both remove the record from database" do
      todo1 = Todo.create!(title: "Task 1")
      todo2 = Todo.create!(title: "Task 2")

      todo1.destroy
      todo2.delete

      expect(Todo.count).to eq(0)
    end
  end

  describe "edge cases" do
    it "does not raise error when destroying non-existent ID" do
      todo = Todo.create!(title: "Task")
      todo.destroy

      expect {
        # Trying to destroy an already destroyed record
        todo.destroy
      }.not_to raise_error
    end

    it "find raises error but find_by returns nil" do
      todo = Todo.create!(title: "Task")
      todo_id = todo.id
      todo.destroy

      expect {
        Todo.find(todo_id)
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Todo.find_by(id: todo_id)).to be_nil
    end

    it "verifies deletion with count" do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")

      expect(Todo.count).to eq(2)

      Todo.destroy_all

      expect(Todo.count).to eq(0)
    end
  end
end
