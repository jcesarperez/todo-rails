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
class Todo < ApplicationRecord
  validates :title, presence: true

  belongs_to :todo_list, optional: true

  def mark_complete
    update(completed: true) unless completed?
    self
  end

  def mark_incomplete
    update(completed: false) if completed?
    self
  end

  def toggle_completion
    update(completed: !completed)
    self
  end
end
