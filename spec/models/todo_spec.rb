require "rails_helper"

RSpec.describe Todo, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "attributes" do
    it "has a title" do
      todo = Todo.new(title: "Learn Rails")
      expect(todo.title).to eq("Learn Rails")
    end

    it "has completed status that defaults to false" do
      todo = Todo.new(title: "Learn Rails")
      expect(todo.completed).to be(false)
    end
  end
end
