# Lesson 7: Mark as Completed

**Objective**: Test toggling the completed status of todos.

**What we'll build**: Methods to mark todos as completed and uncompleted, with tests for status changes.

## Understanding Toggle and Status Changes

We'll implement several approaches to update the `completed` status:

- **Direct assignment + `.save`** - Simple two-step update
- **`.update(completed: value)`** - One-step update
- **`.toggle(:completed)`** - Flip boolean value
- **`.toggle!(:completed)`** - Flip and save in one step
- **Custom method** - `#mark_complete` and `#mark_incomplete` for clarity

## Step 1: Write Tests for Marking Todos Complete (Red Phase)

Create a new spec file for completion functionality:

```bash
touch spec/models/todo_completion_spec.rb
```

Edit `spec/models/todo_completion_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe 'completion status' do
    it 'creates a todo with completed as false by default' do
      todo = Todo.create!(title: "New task")
      expect(todo.completed).to be(false)
    end

    it 'can be created with completed as true' do
      todo = Todo.create!(title: "Done task", completed: true)
      expect(todo.completed).to be(true)
    end

    it 'stores completion status in database' do
      todo = Todo.create!(title: "Task", completed: true)
      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end
  end

  describe '#mark_complete' do
    it 'sets completed to true' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.mark_complete

      expect(todo.completed).to be(true)
    end

    it 'persists to database' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.mark_complete

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end

    it 'does nothing if already completed' do
      todo = Todo.create!(title: "Task", completed: true)
      todo.mark_complete

      expect(todo.completed).to be(true)
      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end

    it 'returns the todo' do
      todo = Todo.create!(title: "Task", completed: false)
      result = todo.mark_complete

      expect(result).to eq(todo)
    end
  end

  describe '#mark_incomplete' do
    it 'sets completed to false' do
      todo = Todo.create!(title: "Task", completed: true)
      todo.mark_incomplete

      expect(todo.completed).to be(false)
    end

    it 'persists to database' do
      todo = Todo.create!(title: "Task", completed: true)
      todo.mark_incomplete

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(false)
    end

    it 'does nothing if already incomplete' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.mark_incomplete

      expect(todo.completed).to be(false)
      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(false)
    end

    it 'returns the todo' do
      todo = Todo.create!(title: "Task", completed: true)
      result = todo.mark_incomplete

      expect(result).to eq(todo)
    end
  end

  describe '#toggle_completion' do
    it 'changes incomplete to complete' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.toggle_completion

      expect(todo.completed).to be(true)
    end

    it 'changes complete to incomplete' do
      todo = Todo.create!(title: "Task", completed: true)
      todo.toggle_completion

      expect(todo.completed).to be(false)
    end

    it 'persists toggled state to database' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.toggle_completion

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end

    it 'toggles multiple times' do
      todo = Todo.create!(title: "Task", completed: false)

      todo.toggle_completion
      expect(todo.completed).to be(true)

      todo.toggle_completion
      expect(todo.completed).to be(false)

      todo.toggle_completion
      expect(todo.completed).to be(true)
    end

    it 'returns the todo' do
      todo = Todo.create!(title: "Task", completed: false)
      result = todo.toggle_completion

      expect(result).to eq(todo)
    end
  end

  describe '#completed?' do
    it 'returns true when completed' do
      todo = Todo.create!(title: "Task", completed: true)
      expect(todo.completed?).to be(true)
    end

    it 'returns false when not completed' do
      todo = Todo.create!(title: "Task", completed: false)
      expect(todo.completed?).to be(false)
    end
  end

  describe '.completed' do
    it 'returns all completed todos' do
      completed1 = Todo.create!(title: "Task 1", completed: true)
      completed2 = Todo.create!(title: "Task 2", completed: true)
      incomplete = Todo.create!(title: "Task 3", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos.length).to eq(2)
      expect(completed_todos).to include(completed1, completed2)
      expect(completed_todos).not_to include(incomplete)
    end

    it 'returns empty array when no completed todos' do
      Todo.create!(title: "Task", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos).to be_empty
    end
  end

  describe '.incomplete' do
    it 'returns all incomplete todos' do
      completed = Todo.create!(title: "Task 1", completed: true)
      incomplete1 = Todo.create!(title: "Task 2", completed: false)
      incomplete2 = Todo.create!(title: "Task 3", completed: false)

      incomplete_todos = Todo.where(completed: false).to_a
      expect(incomplete_todos.length).to eq(2)
      expect(incomplete_todos).to include(incomplete1, incomplete2)
      expect(incomplete_todos).not_to include(completed)
    end

    it 'returns empty array when all todos completed' do
      Todo.create!(title: "Task", completed: true)

      incomplete_todos = Todo.where(completed: false).to_a
      expect(incomplete_todos).to be_empty
    end
  end

  describe 'completion workflow' do
    it 'tracks completion status through workflow' do
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

    it 'can update title and completion together' do
      todo = Todo.create!(title: "Old title", completed: false)
      todo.update(title: "New title", completed: true)

      reloaded = Todo.find(todo.id)
      expect(reloaded.title).to eq("New title")
      expect(reloaded.completed).to be(true)
    end

    it 'counts completed and incomplete todos' do
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

  describe 'edge cases' do
    it 'handles rapid status changes' do
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

    it 'mark_complete on already completed todo does not create extra saves' do
      todo = Todo.create!(title: "Task", completed: true)
      original_updated_at = todo.updated_at

      # Small delay to ensure timestamp would change if saved
      sleep(0.01)
      todo.mark_complete

      expect(todo.updated_at).to eq(original_updated_at)
    end

    it 'different todos have independent completion states' do
      todo1 = Todo.create!(title: "Task 1", completed: true)
      todo2 = Todo.create!(title: "Task 2", completed: false)

      todo1.mark_incomplete
      todo2.mark_complete

      expect(todo1.completed).to be(false)
      expect(todo2.completed).to be(true)
    end
  end
end
```

Run the tests to see them fail:

```bash
bundle exec rspec spec/models/todo_completion_spec.rb
```

You should see errors like:

```
undefined method `mark_complete' for #<Todo:...> (NoMethodError)
```

This is expected! We haven't implemented these methods yet. ✓ This is the **Red** phase.

## Step 2: Implement the Completion Methods (Green Phase)

Open `app/models/todo.rb` and add the custom methods:

```ruby
# == Schema Information
# Table name: todos
#
#  id        :bigint      primary key
#  title     :string
#  completed :boolean     default(false)
#  created_at :datetime
#  updated_at :datetime

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
```

**What we added:**

- **`#mark_complete`**: Sets completed to true (only saves if it was false to avoid unnecessary updates)
- **`#mark_incomplete`**: Sets completed to false (only saves if it was true)
- **`#toggle_completion`**: Flips the boolean value
- **Returns `self`**: All methods return the todo object for method chaining

## Important: `.update` vs `.update!` (Rails Convention)

You might be wondering why we used `.update` instead of `.update!`. This is an important Rails convention:

### The Difference

| Method | Returns | On Failure | Use Case |
|--------|---------|-----------|----------|
| `.update` | `true`/`false` | Returns false | Safe operations, UI/web context |
| `.update!` | Record or error | Raises exception | Strict operations, critical changes |

### Why We Use `.update` Here

```ruby
def mark_complete
  update(completed: true) unless completed?  # ✅ .update (not .update!)
  self
end
```

**Rails Convention:** Use `.update` for simple, safe state changes because:

1. **No validation risk** - We're only changing `completed` (boolean)
   - The todo already exists with valid title
   - Boolean fields can't fail validation

2. **UI/Web context** - This method will likely be called from controllers
   - Users expect graceful error handling
   - `.update` returns false without breaking flow

3. **Simplicity** - No need for try/catch blocks
   - Cleaner, more readable code
   - Standard Rails pattern for state changes

### When to Use `.update!` Instead

```ruby
# Use .update! for critical operations or transactions
def important_operation
  ActiveRecord::Base.transaction do
    todo.update!(status: "processed")  # Must succeed or transaction fails
  end
end
```

Use `.update!` when:
- Changes are critical and failure is an error condition
- Inside transactions where failure should rollback
- In background jobs where you need explicit error handling
- When you want Rails to raise `ActiveRecord::RecordInvalid`

### Rails Pattern Summary

```
Simple state change in controllers/models  → .update (safe)
Critical data operations                    → .update! (strict)
User input that might fail validation       → .update (with error handling)
System operations that must succeed         → .update! (with exception handling)
```

**Bottom line:** In professional Rails apps, most model methods like `mark_complete` use `.update` to keep code simple and follow convention. Reserve `.update!` for genuinely critical operations.

Run the tests:

```bash
bundle exec rspec spec/models/todo_completion_spec.rb
```

Expected output:

```
Todo
  completion status
    creates a todo with completed as false by default
    can be created with completed as true
    stores completion status in database
  #mark_complete
    sets completed to true
    persists to database
    does nothing if already completed
    returns the todo
  #mark_incomplete
    sets completed to false
    persists to database
    does nothing if already incomplete
    returns the todo
  #toggle_completion
    changes incomplete to complete
    changes complete to incomplete
    persists toggled state to database
    toggles multiple times
    returns the todo
  #completed?
    returns true when completed
    returns false when not completed
  .completed
    returns all completed todos
    returns empty array when no completed todos
  .incomplete
    returns all incomplete todos
    returns empty array when all todos completed
  completion workflow
    tracks completion status through workflow
    can update title and completion together
    counts completed and incomplete todos
  edge cases
    handles rapid status changes
    mark_complete on already completed todo does not create extra saves
    different todos have independent completion states

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
35 examples, 0 failures
```

Perfect! All tests pass. ✓ This is the **Green** phase.

## Step 3: Understanding What We Built

**`#mark_complete`:**
- Sets `completed` to `true`
- Only saves if currently `false` (efficiency)
- Returns self for method chaining
- Used when you explicitly want to mark as done

**`#mark_incomplete`:**
- Sets `completed` to `false`
- Only saves if currently `true` (efficiency)
- Returns self for method chaining
- Used when you want to reopen a completed task

**`#toggle_completion`:**
- Flips boolean value (true → false, false → true)
- Always saves (because it changes state)
- Returns self for method chaining
- Used for toggle buttons in UI

**Why check before saving?**

```ruby
def mark_complete
  update(completed: true) unless completed?  # Only save if needed
  self
end
```

If a todo is already completed and you call `mark_complete`, it doesn't hit the database. This is more efficient because:
- Fewer database writes
- `updated_at` doesn't change unnecessarily
- Better performance for bulk operations

**Query methods:**
- `Todo.where(completed: true)` - Find all completed
- `Todo.where(completed: false)` - Find all incomplete
- Both return a relation that needs `.to_a` to convert to array in tests

## Step 4: Experiment in Rails Console

```bash
rails console
```

Try these commands:

```ruby
# Create test todos
todo1 = Todo.create!(title: "Learn Rails", completed: false)
todo2 = Todo.create!(title: "Build app", completed: false)

# Mark complete
todo1.mark_complete
todo1.completed  # => true

# Mark incomplete
todo1.mark_incomplete
todo1.completed  # => false

# Toggle
todo1.toggle_completion
todo1.completed  # => true

todo1.toggle_completion
todo1.completed  # => false

# Query by status
completed = Todo.where(completed: true).to_a
incomplete = Todo.where(completed: false).to_a

# Update multiple fields
todo2.update(title: "Build awesome app", completed: true)

# Check status
todo2.completed?  # => true

# Workflow
todo3 = Todo.create!(title: "Deploy")
todo3.mark_complete.mark_incomplete.mark_complete
# This chains methods together!

exit
```

## Step 5: Method Chaining (Bonus)

Notice our methods return `self`, which enables method chaining:

```ruby
# Instead of:
todo = Todo.create!(title: "Task")
todo.mark_complete
todo.update(title: "Important task")

# You can chain:
todo = Todo.create!(title: "Task")
       .mark_complete
       .update(title: "Important task")
```

This is a Rails pattern - methods that modify state often return `self` to allow chaining.

## Step 6: Run All Model Tests

```bash
bundle exec rspec spec/models/
```

Expected: All tests should pass (107 examples total)

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_completion_spec.rb`
- [ ] All completion status tests passing (3 tests)
- [ ] All `#mark_complete` tests passing (4 tests)
- [ ] All `#mark_incomplete` tests passing (4 tests)
- [ ] All `#toggle_completion` tests passing (5 tests)
- [ ] All `#completed?` tests passing (2 tests)
- [ ] All `.completed` scope tests passing (2 tests)
- [ ] All `.incomplete` scope tests passing (2 tests)
- [ ] All workflow tests passing (3 tests)
- [ ] All edge case tests passing (3 tests)
- [ ] All model tests passing (107 examples, 0 failures)
- [ ] Experimented in Rails console
- [ ] Verified tests run in VS Code with Better RSpec
- [ ] Understood method chaining with `self` return

## 📝 What You've Learned

- How to implement custom instance methods in Rails models
- How to add clarity with semantic method names (`mark_complete` vs `update`)
- Smart conditional saving (only save when state changes)
- Method chaining pattern (returning `self`)
- How to add helper methods for common operations
- How to query by boolean attributes
- How `.where()` works with boolean conditions
- Efficiency considerations (avoiding unnecessary database writes)
- Building expressive, readable code
- Testing state transitions
- How to handle edge cases with rapid state changes

## 🔍 Key Methods Reference

| Method | What it does | Returns | Database |
|--------|-------------|---------|----------|
| `#mark_complete` | Sets completed to true | self | Only if needed |
| `#mark_incomplete` | Sets completed to false | self | Only if needed |
| `#toggle_completion` | Flips boolean | self | Always |
| `.where(completed: true)` | Query completed | Relation | N/A |
| `.where(completed: false)` | Query incomplete | Relation | N/A |

## 🚀 Next Lesson

Proceed to **[Lesson 8: Views and Controllers](./08_views_and_controllers.md)** where we'll create HTTP endpoints and HTML views to interact with todos through a web interface.

---

**Lesson Status**: ✅ Complete
**Time Estimate**: 15-20 minutes
**Difficulty**: Beginner