# == Schema Information
#
# Table name: todos
#
#  id           :integer          not null, primary key
#  completed    :boolean          default(FALSE)
#  title        :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  todo_list_id :integer
#
# Indexes
#
#  index_todos_on_todo_list_id  (todo_list_id)
#
# Foreign Keys
#
#  todo_list_id  (todo_list_id => todo_lists.id)
#
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

    it "has timestamps" do
      todo = Todo.create!(title: "Learn Rails")
      expect(todo.id).not_to be_nil
      expect(todo.created_at).not_to be_nil
      expect(todo.updated_at).not_to be_nil
    end

    it "created_at and updated_at are initially the same" do
      todo = Todo.create!(title: "Learn Rails")
      expect(todo.created_at).to eq(todo.updated_at)
    end
  end
end
