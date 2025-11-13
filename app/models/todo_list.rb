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
class TodoList < ApplicationRecord
  validates :title, presence: true, uniqueness: true

  has_many :todos, dependent: :destroy
end
