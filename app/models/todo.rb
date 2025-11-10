# == Schema Information
#
# Table name: todos
#
#  id         :integer          not null, primary key
#  completed  :boolean          default(FALSE)
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Todo < ApplicationRecord
  validates :title, presence: true

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
