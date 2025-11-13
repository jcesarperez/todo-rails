# Lesson 9: TodoList Model

**Objective**: Create a TodoList model and establish relationships between TodoLists and Todos.

**What we'll build**: A TodoList model with validations, associations, and comprehensive tests.

## Understanding the Relationship

We're adding a new entity to organize todos:

**Before:**
```
Todos (standalone)
- Learn Rails
- Build app
- Deploy
```

**After:**
```
TodoList: "My Project"
├── Todo: Learn Rails
├── Todo: Build app
└── Todo: Deploy

TodoList: "Shopping"
├── Todo: Buy milk
└── Todo: Buy eggs
```

**Relationship type:** One TodoList has many Todos (1:N)

---

## Step 1: Write Tests for TodoList Model (Red Phase)

Create a new spec file:

```bash
touch spec/models/todo_list_spec.rb
```

Edit `spec/models/todo_list_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe TodoList, type: :model do
  describe 'validations' do
    subject { TodoList.new(title: "Test List") }
    
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:todos).dependent(:destroy) }
  end

  describe 'attributes' do
    it 'has a title' do
      todo_list = TodoList.new(title: "My List")
      expect(todo_list.title).to eq("My List")
    end

    it 'has timestamps' do
      todo_list = TodoList.create!(title: "My List")
      expect(todo_list.id).not_to be_nil
      expect(todo_list.created_at).not_to be_nil
      expect(todo_list.updated_at).not_to be_nil
    end
  end

  describe '.create' do
    it 'creates a new todo_list with valid title' do
      todo_list = TodoList.create(title: "Shopping List")
      expect(todo_list).to be_persisted
      expect(todo_list.title).to eq("Shopping List")
    end

    it 'does not create without title' do
      todo_list = TodoList.create(title: "")
      expect(todo_list).not_to be_persisted
      expect(todo_list.errors.full_messages).to include("Title can't be blank")
    end

    it 'does not create with duplicate title' do
      TodoList.create!(title: "My List")
      duplicate = TodoList.create(title: "My List")
      
      expect(duplicate).not_to be_persisted
      expect(duplicate.errors.full_messages).to include("Title has already been taken")
    end
  end

  describe 'associations with todos' do
    let(:todo_list) { TodoList.create!(title: "My List") }

    it 'can have multiple todos' do
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")
      todo3 = todo_list.todos.create!(title: "Task 3")

      expect(todo_list.todos.count).to eq(3)
      expect(todo_list.todos).to include(todo1, todo2, todo3)
    end

    it 'destroys associated todos when destroyed' do
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")
      todo_ids = [todo1.id, todo2.id]

      todo_list.destroy

      expect(Todo.where(id: todo_ids)).to be_empty
    end

    it 'todos belong to the todo_list' do
      todo = todo_list.todos.create!(title: "Task")
      expect(todo.todo_list).to eq(todo_list)
    end
  end

  describe 'todo_lists queries' do
    it 'returns all todo_lists' do
      list1 = TodoList.create!(title: "List 1")
      list2 = TodoList.create!(title: "List 2")

      all_lists = TodoList.all
      expect(all_lists.length).to eq(2)
      expect(all_lists).to include(list1, list2)
    end

    it 'returns empty when no todo_lists' do
      expect(TodoList.all).to be_empty
    end

    it 'finds todo_list by id' do
      todo_list = TodoList.create!(title: "My List")
      found = TodoList.find(todo_list.id)
      expect(found).to eq(todo_list)
    end

    it 'finds todo_list by title' do
      todo_list = TodoList.create!(title: "Shopping")
      found = TodoList.find_by(title: "Shopping")
      expect(found).to eq(todo_list)
    end
  end

  describe 'updating todo_list' do
    it 'updates title' do
      todo_list = TodoList.create!(title: "Original")
      todo_list.update(title: "Updated")
      expect(todo_list.reload.title).to eq("Updated")
    end

    it 'does not update to empty title' do
      todo_list = TodoList.create!(title: "Original")
      result = todo_list.update(title: "")
      expect(result).to be(false)
      expect(todo_list.reload.title).to eq("Original")
    end

    it 'does not update to duplicate title' do
      list1 = TodoList.create!(title: "List 1")
      list2 = TodoList.create!(title: "List 2")
      
      result = list2.update(title: "List 1")
      expect(result).to be(false)
      expect(list2.reload.title).to eq("List 2")
    end
  end

  describe 'deleting todo_list' do
    it 'deletes a todo_list' do
      todo_list = TodoList.create!(title: "Delete me")
      todo_list_id = todo_list.id

      todo_list.destroy

      expect(TodoList.find_by(id: todo_list_id)).to be_nil
    end

    it 'also deletes associated todos' do
      todo_list = TodoList.create!(title: "List")
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")

      todo_list.destroy

      expect(Todo.find_by(id: todo1.id)).to be_nil
      expect(Todo.find_by(id: todo2.id)).to be_nil
    end
  end

  describe 'todo_list interactions' do
    it 'maintains todos even if todo_list is updated' do
      todo_list = TodoList.create!(title: "Original")
      todo = todo_list.todos.create!(title: "Task")
      
      todo_list.update(title: "Updated")
      
      expect(todo.reload.todo_list_id).to eq(todo_list.id)
    end

    it 'can move a todo to a different list' do
      list1 = TodoList.create!(title: "List 1")
      list2 = TodoList.create!(title: "List 2")
      todo = list1.todos.create!(title: "Task")

      todo.update(todo_list_id: list2.id)

      expect(list1.todos.count).to eq(0)
      expect(list2.todos.count).to eq(1)
      expect(todo.reload.todo_list).to eq(list2)
    end

    it 'todos without list are independent' do
      todo = Todo.create!(title: "Independent task")
      expect(todo.todo_list).to be_nil
    end
  end
end
```

Run the tests to see them fail:

```bash
bundle exec rspec spec/models/todo_list_spec.rb
```

You should see errors like:
```
uninitialized constant TodoList (NameError)
```

This is expected! ✓ This is the **Red** phase.

---

## Step 2: Generate the TodoList Model (Green Phase)

Generate the TodoList model:

```bash
rails generate model TodoList title:string --skip-test
```

This creates:
- `app/models/todo_list.rb`
- `db/migrate/[timestamp]_create_todo_lists.rb`

**Important Note on Rails Naming Convention:**
- Model class name: `TodoList` (CamelCase)
- Model file name: `todo_list.rb` (snake_case)
- Table name: `todo_lists` (snake_case with underscores)
- Foreign key column: `todo_list_id` (snake_case with underscores)

Rails generates these correctly automatically. The migration file will already have `create_table :todo_lists`.

### Step 2a: Update the CreateTodoLists migration

Open `db/migrate/[timestamp]_create_todo_lists.rb` and update it:

```ruby
class CreateTodoLists < ActiveRecord::Migration[7.1]
  def change
    create_table :todo_lists do |t|
      t.string :title, null: false
      t.timestamps
    end
    
    add_index :todo_lists, :title, unique: true
  end
end
```

**What changed:**
- `null: false` - Title cannot be null
- `add_index :todo_lists, :title, unique: true` - Enforces uniqueness at database level

### Step 2b: Add foreign key to todos table

Create a new migration to add the reference:

```bash
rails generate migration AddTodoListToTodos todo_list:references --skip-test
```

Open the generated migration file and verify it contains:

```ruby
class AddTodoListToTodos < ActiveRecord::Migration[7.1]
  def change
    add_reference :todos, :todo_list, null: true, foreign_key: true
  end
end
```

**What this does:**
- Adds `todo_list_id` column to todos table
- `null: true` - A todo can exist without a list (for backwards compatibility)
- `foreign_key: true` - Enforces referential integrity at database level

### Step 2c: Run migrations

```bash
rails db:migrate
```

### Step 2d: Update the TodoList model

Edit `app/models/todo_list.rb`:

```ruby
class TodoList < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  
  has_many :todos, dependent: :destroy
end
```

### Step 2e: Update the Todo model

Edit `app/models/todo.rb` and ADD the association (keep all existing code):

```ruby
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
```

**Important:** Only ADD the `belongs_to :todo_list, optional: true` line. Keep all your existing business logic methods.

### Step 2f: Annotate models

```bash
bundle exec annotate
```

Run the tests:

```bash
bundle exec rspec spec/models/todo_list_spec.rb
```

All tests should pass! ✓ This is the **Green** phase.

---

## Step 3: Test TodoList and Todo Interactions

Create a new spec file to test the full interaction:

```bash
touch spec/models/todo_list_todo_interaction_spec.rb
```

Edit `spec/models/todo_list_todo_interaction_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "TodoList and Todo Interaction", type: :model do
  describe 'creating todos in a list' do
    it 'creates todos associated with a todo_list' do
      list = TodoList.create!(title: "Shopping")
      
      list.todos.create!(title: "Milk")
      list.todos.create!(title: "Bread")
      list.todos.create!(title: "Eggs")

      expect(list.todos.count).to eq(3)
      expect(list.todos.map(&:title)).to include("Milk", "Bread", "Eggs")
    end

    it 'marks todos as completed in a list' do
      list = TodoList.create!(title: "Work")
      todo1 = list.todos.create!(title: "Task 1", completed: false)
      todo2 = list.todos.create!(title: "Task 2", completed: true)

      completed = list.todos.where(completed: true)
      expect(completed.count).to eq(1)
      expect(completed.first.title).to eq("Task 2")
    end

    it 'gets incomplete todos in a list' do
      list = TodoList.create!(title: "Work")
      list.todos.create!(title: "Done", completed: true)
      list.todos.create!(title: "Pending 1", completed: false)
      list.todos.create!(title: "Pending 2", completed: false)

      pending = list.todos.where(completed: false)
      expect(pending.count).to eq(2)
    end
  end

  describe 'deleting lists cascades to todos' do
    it 'deletes all todos when list is deleted' do
      list = TodoList.create!(title: "Temporary")
      list.todos.create!(title: "Task 1")
      list.todos.create!(title: "Task 2")

      todo_ids = list.todos.pluck(:id)
      list.destroy

      expect(Todo.where(id: todo_ids)).to be_empty
    end
  end

  describe 'todos can be independent or in lists' do
    it 'has independent todos without a list' do
      todo = Todo.create!(title: "Standalone")
      expect(todo.todo_list).to be_nil
      expect(todo.todo_list_id).to be_nil
    end

    it 'can query all todos with lists' do
      list = TodoList.create!(title: "List 1")
      list.todos.create!(title: "In list")
      Todo.create!(title: "Independent")

      todos_with_list = Todo.where.not(todo_list_id: nil)
      expect(todos_with_list.count).to eq(1)
    end

    it 'can query all todos without lists' do
      list = TodoList.create!(title: "List 1")
      list.todos.create!(title: "In list")
      Todo.create!(title: "Independent")

      todos_without_list = Todo.where(todo_list_id: nil)
      expect(todos_without_list.count).to eq(1)
    end
  end
end
```

Run the tests:

```bash
bundle exec rspec spec/models/todo_list_todo_interaction_spec.rb
```

All should pass! ✅

---

## Step 4: Run All Model Tests

```bash
bundle exec rspec spec/models/
```

Expected output:
```
TodoList
  validations
    validates presence of title
    validates uniqueness of title
  associations
    has many todos
  [... many more examples ...]

Todo
  [... existing tests ...]

Finished in X.XXXXX seconds (files took X.XXXXX seconds to load)
XXX examples, 0 failures ✅
```

---

## Understanding Associations

### `has_many` (One-to-Many)

```ruby
class TodoList < ApplicationRecord
  has_many :todos, dependent: :destroy
end
```

**What this does:**
- TodoList can have multiple Todos
- `dependent: :destroy` - When a TodoList is deleted, its Todos are also deleted
- Adds methods: `list.todos`, `list.todos.create`, `list.todos.build`, etc.

### `belongs_to` (Reverse of has_many)

```ruby
class Todo < ApplicationRecord
  belongs_to :todo_list, optional: true
end
```

**What this does:**
- Todo belongs to a TodoList
- `optional: true` - A Todo can exist without a TodoList
- Adds methods: `todo.todo_list`, `todo.todo_list_id=`, etc.

### Uniqueness Validation

```ruby
validates :title, presence: true, uniqueness: true
```

**What this does:**
- Validates at the Rails level (prevents duplicates in application)
- Combined with database index, prevents duplicates at database level
- Better than database-only constraint because error message is user-friendly

---

## Database Constraints

The migration creates:

```ruby
# Column
t.string :title, null: false

# Index for uniqueness
add_index :todo_lists, :title, unique: true

# Foreign key
add_reference :todos, :todo_list, null: true, foreign_key: true
```

**What this ensures:**
- ✅ Title cannot be NULL
- ✅ No duplicate titles (database level)
- ✅ Every todo's `todo_list_id` refers to valid TodoList
- ✅ Referential integrity is maintained

---

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_list_spec.rb` with all tests
- [ ] All TodoList model tests passing (25+ tests)
- [ ] Generated TodoList model with `rails generate`
- [ ] Updated migration with `null: false` and unique index
- [ ] Added `todo_list_id` to todos table with migration
- [ ] Ran `rails db:migrate`
- [ ] Updated `app/models/todo_list.rb` with association
- [ ] Updated `app/models/todo.rb` with association
- [ ] Ran `bundle exec annotate`
- [ ] Created interaction tests
- [ ] All model tests passing (150+ total examples)
- [ ] Verified Rails console associations work

## 📝 What You've Learned

- How to generate models with Rails
- Rails naming conventions (CamelCase class, snake_case files/tables)
- Database migrations with foreign keys
- Uniqueness validations and indexes
- `has_many` and `belongs_to` associations
- `dependent: :destroy` cascade behavior
- `optional: true` for optional associations
- Querying through associations
- Annotation with schema comments
- Testing associations with RSpec
- Database constraints and referential integrity
- One-to-many relationships in Rails

## 🔍 Key Association Methods

| Method | Purpose |
|--------|---------|
| `list.todos` | Get all todos for list |
| `list.todos.create!(title: "...")` | Create todo in list |
| `list.todos.count` | Count todos in list |
| `list.todos.where(completed: true)` | Filter todos in list |
| `todo.todo_list` | Get the list for a todo |
| `todo.todo_list_id` | Get the list ID |
| `todo.belongs_to?(:todo_list)` | Check association exists |

## 🚀 Next Lesson

Proceed to **[Lesson 10: TodoList Views and Controllers](./10_todolist_views_controllers.md)** where we'll create HTTP endpoints and views for managing TodoLists.

---

**Lesson Status**: ✅ Complete
**Time Estimate**: 25-30 minutes
**Difficulty**: Beginner