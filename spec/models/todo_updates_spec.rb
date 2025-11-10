require "rails_helper"

RSpec.describe Todo, type: :model do
  describe ".update" do
    it "updates a single attribute" do
      todo = Todo.create!(title: "Original title")
      result = todo.update(title: "Updated title")

      expect(result).to be(true)
      expect(todo.title).to eq("Updated title")
    end

    it "updates multiple attributes at once" do
      todo = Todo.create!(title: "Task", completed: false)
      result = todo.update(title: "New task", completed: true)

      expect(result).to be(true)
      expect(todo.title).to eq("New task")
      expect(todo.completed).to be(true)
    end

    it "persists changes to database" do
      todo = Todo.create!(title: "Original")
      todo.update(title: "Updated")

      # Fetch from database again
      reloaded = Todo.find(todo.id)
      expect(reloaded.title).to eq("Updated")
    end

    it "returns false when validation fails" do
      todo = Todo.create!(title: "Task")
      result = todo.update(title: "")

      expect(result).to be(false)
      # Reload to get the actual database value
      todo.reload
      expect(todo.title).to eq("Task")  # Not updated in database
    end

    it "does not save if validation fails" do
      todo = Todo.create!(title: "Task")
      todo.update(title: "")

      reloaded = Todo.find(todo.id)
      expect(reloaded.title).to eq("Task")  # Original value in database
    end

    it "populates errors when update fails" do
      todo = Todo.create!(title: "Task")
      todo.update(title: "")

      expect(todo.errors.full_messages).to include("Title can't be blank")
    end
  end

  describe ".update!" do
    it "updates attributes and returns true on success" do
      todo = Todo.create!(title: "Original")
      result = todo.update!(title: "Updated")

      expect(result).to be(true)
      expect(todo.title).to eq("Updated")
    end

    it "raises error when validation fails" do
      todo = Todo.create!(title: "Task")

      expect {
        todo.update!(title: "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "does not update when validation fails" do
      todo = Todo.create!(title: "Task")

      begin
        todo.update!(title: "")
      rescue ActiveRecord::RecordInvalid
        # Expected error
      end

      reloaded = Todo.find(todo.id)
      expect(reloaded.title).to eq("Task")  # Not updated
    end
  end

  describe "direct assignment and save" do
    it "updates attribute via direct assignment don't persist automatically" do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"

      expect(todo.title).to eq("Updated")  # Updated in memory
      expect(Todo.find(todo.id).title).to eq("Original")  # Not in database yet
    end

    it "persists changes with .save" do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"
      result = todo.save

      expect(result).to be(true)
      expect(Todo.find(todo.id).title).to eq("Updated")
    end

    it "returns false if validation fails on save" do
      todo = Todo.create!(title: "Task")
      todo.title = ""
      result = todo.save

      expect(result).to be(false)
      expect(todo.errors.full_messages).to include("Title can't be blank")
    end

    it "can update completed status" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.completed = true
      todo.save

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end
  end

  describe "tracking changes" do
    it "tracks attribute changes before save" do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"

      expect(todo.changed?).to be(true)
      expect(todo.changes).to include("title" => ["Original", "Updated"])
    end

    it "clears changes after save" do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"
      todo.save

      expect(todo.changed?).to be(false)
      expect(todo.changes).to be_empty
    end

    it "tracks what attributes changed" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.title = "New task"
      todo.completed = true

      expect(todo.changed_attributes).to include("title", "completed")
    end
  end

  describe "reloading from database" do
    it "reloads data from database with .reload" do
      todo = Todo.create!(title: "Original")
      todo.title = "Changed in memory"

      expect(todo.title).to eq("Changed in memory")

      todo.reload
      expect(todo.title).to eq("Original")  # Reloaded from database
    end

    it "discards unsaved changes" do
      todo = Todo.create!(title: "Task", completed: false)
      todo.completed = true

      todo.reload
      expect(todo.changed?).to be(false)
      expect(todo.changes).to be_empty
      expect(todo.completed).to be(false)  # Changes discarded
    end
  end
end
