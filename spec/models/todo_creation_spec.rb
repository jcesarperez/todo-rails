require "rails_helper"

RSpec.describe Todo, type: :model do
  describe ".create" do
    it "creates a new todo with valid attributes" do
      todo = Todo.create(title: "Buy groceries")
      expect(todo).to be_persisted
      expect(todo.title).to eq("Buy groceries")
    end

    it "creates a todo with completed as false by default" do
      todo = Todo.create(title: "Buy groceries")
      expect(todo.completed).to be(false)
    end

    it "does not save a todo without a title" do
      todo = Todo.create(title: "")
      expect(todo).not_to be_persisted
    end

    it "returns nil when create fails validation" do
      todo = Todo.create(title: nil)
      expect(todo).not_to be_persisted
      expect(todo.id).to be_nil
    end
  end

  describe ".create!" do
    it "creates a new todo with valid attributes" do
      todo = Todo.create!(title: "Learn Rails")
      expect(todo).to be_persisted
      expect(todo.id).not_to be_nil
    end

    it "raises an error when validation fails" do
      expect {
        Todo.create!(title: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "#new and #save" do
    it "creates a todo in memory and saves it" do
      todo = Todo.new(title: "Complete lesson")
      expect(todo).not_to be_persisted

      todo.save
      expect(todo).to be_persisted
    end

    it "returns false when save fails" do
      todo = Todo.new(title: "")
      result = todo.save
      expect(result).to be(false)
    end

    it "returns true when save succeeds" do
      todo = Todo.new(title: "Success")
      result = todo.save
      expect(result).to be(true)
    end
  end
end
