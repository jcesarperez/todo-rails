# Lesson 5: Update Todos

**Objective**: Test updating todo attributes and persisting changes to the database.

**What we'll build**: Methods to update todo attributes and validate changes.

## Understanding Update Methods

Rails provides several ways to update records:

- **`.update(attributes)`** - Updates and saves, returns true/false
- **`.update!(attributes)`** - Updates and saves, raises error on failure
- **Direct assignment + `.save`** - Two-step update process
- **`.save`** - Persists changes after direct assignment

## Step 1: Write Tests for Updating Todos (Red Phase)

Create a new spec file for updating todos:

```bash
touch spec/models/todo_updates_spec.rb
```

Edit `spec/models/todo_updates_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe '.update' do
    it 'updates a single attribute' do
      todo = Todo.create!(title: "Original title")
      result = todo.update(title: "Updated title")

      expect(result).to be(true)
      expect(todo.title).to eq("Updated title")
    end

    it 'updates multiple attributes at once' do
      todo = Todo.create!(title: "Task", completed: false)
      result = todo.update(title: "New task", completed: true)

      expect(result).to be(true)
      expect(todo.title).to eq("New task")
      expect(todo.completed).to be(true)
    end

    it 'persists changes to database' do
      todo = Todo.create!(title: "Original")
      todo.update(title: "Updated")

      # Fetch from database again
      reloaded = Todo.find(todo.id)
      expect(reloaded.title).to eq("Updated")
    end

    it 'returns false when validation fails' do
      todo = Todo.create!(title: "Task")
      result = todo.update(title: "")

      expect(result).to be(false)
      # Reload to get the actual database value
      todo.reload
      expect(todo.title).to eq("Task")  # Not updated in database
    end

    it 'does not save if validation fails' do
      todo = Todo.create!(title: "Task")
      todo.update(title: "")

      reloaded = Todo.find(todo.id)
      expect(reloaded.title).to eq("Task")  # Original value in database
    end

    it 'populates errors when update fails' do
      todo = Todo.create!(title: "Task")
      todo.update(title: "")

      expect(todo.errors.full_messages).to include("Title can't be blank")
    end
  end

  describe '.update!' do
    it 'updates attributes and returns true on success' do
      todo = Todo.create!(title: "Original")
      result = todo.update!(title: "Updated")

      expect(result).to be(true)
      expect(todo.title).to eq("Updated")
    end

    it 'raises error when validation fails' do
      todo = Todo.create!(title: "Task")

      expect {
        todo.update!(title: "")
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not update when validation fails' do
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

  describe 'direct assignment and save' do
    it 'updates attribute via direct assignment' do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"

      expect(todo.title).to eq("Updated")  # Updated in memory
      expect(Todo.find(todo.id).title).to eq("Original")  # Not in database yet
    end

    it 'persists changes with .save' do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"
      result = todo.save

      expect(result).to be(true)
      expect(Todo.find(todo.id).title).to eq("Updated")
    end

    it 'returns false if validation fails on save' do
      todo = Todo.create!(title: "Task")
      todo.title = ""
      result = todo.save

      expect(result).to be(false)
      expect(todo.errors.full_messages).to include("Title can't be blank")
    end

    it 'can update completed status' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.completed = true
      todo.save

      reloaded = Todo.find(todo.id)
      expect(reloaded.completed).to be(true)
    end
  end

  describe 'tracking changes' do
    it 'tracks attribute changes before save' do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"

      expect(todo.changed?).to be(true)
      expect(todo.changes).to include("title" => ["Original", "Updated"])
    end

    it 'clears changes after save' do
      todo = Todo.create!(title: "Original")
      todo.title = "Updated"
      todo.save

      expect(todo.changed?).to be(false)
      expect(todo.changes).to be_empty
    end

    it 'tracks what attributes changed' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.title = "New task"
      todo.completed = true

      expect(todo.changed_attributes).to include("title", "completed")
    end
  end

  describe 'reloading from database' do
    it 'reloads data from database with .reload' do
      todo = Todo.create!(title: "Original")
      todo.title = "Changed in memory"

      expect(todo.title).to eq("Changed in memory")

      todo.reload
      expect(todo.title).to eq("Original")  # Reloaded from database
    end

    it 'discards unsaved changes' do
      todo = Todo.create!(title: "Task", completed: false)
      todo.completed = true

      todo.reload
      expect(todo.completed).to be(false)  # Changes discarded
    end
  end
end
```

Run the tests to see them pass:

```bash
bundle exec rspec spec/models/todo_updates_spec.rb
```

Expected output:

```
Todo
  .update
    updates a single attribute
    updates multiple attributes at once
    persists changes to database
    returns false when validation fails
    does not save if validation fails
    populates errors when update fails
  .update!
    updates attributes and returns the record
    raises error when validation fails
    does not update when validation fails
  direct assignment and save
    updates attribute via direct assignment
    persists changes with .save
    returns false if validation fails on save
    can update completed status
  tracking changes
    tracks attribute changes before save
    clears changes after save
    tracks what attributes changed
  reloading from database
    reloads data from database with .reload
    discards unsaved changes

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
18 examples, 0 failures
```

Perfect! All tests pass because Rails ActiveRecord provides these methods automatically. ✓ This is the **Green** phase.

## Step 2: Understanding What We Tested

**`.update(attributes)`:**
- ✅ Updates one or multiple attributes at once
- ✅ Saves to database automatically
- ✅ Returns true if successful, false if validation fails
- ✅ **Important**: Updates object in memory even if validation fails
- ✅ Use `.reload` to get actual database values after failed update
- ✅ Populates `errors` on failure

**`.update!(attributes)`:**
- ✅ Updates and saves like `.update`
- ✅ Raises `ActiveRecord::RecordInvalid` on validation failure
- ✅ Does not update in memory if validation fails
- ✅ Returns true on success
- ✅ Use when you want errors to bubble up

**Direct assignment + `.save`:**
- ✅ Assign new values to attributes
- ✅ Changes are only in memory until `.save`
- ✅ `.save` persists to database
- ✅ Returns true/false based on success
- ✅ If validation fails, object in memory is modified but not saved

**Tracking changes:**
- ✅ `.changed?` - Returns true if attributes were modified
- ✅ `.changes` - Returns hash of changed attributes
- ✅ `.changed_attributes` - Returns array of changed attribute names

**`.reload`:**
- ✅ Discards in-memory changes
- ✅ Reloads data from database
- ✅ Useful after failed updates to get actual database values
- ✅ Essential in tests when validation fails

## Important: In-Memory vs Database State

This is a critical concept to understand:

```ruby
todo = Todo.create!(title: "Task")

# Try to update with invalid data
result = todo.update(title: "")

# In memory (what the Ruby object shows)
todo.title  # => "" (was updated in memory)

# In database (what's actually saved)
Todo.find(todo.id).title  # => "Task" (not updated)

# Reload to sync with database
todo.reload
todo.title  # => "Task" (now matches database)
```

**Why this matters:**
- `.update` modifies the object in memory even if validation fails
- The database is NOT updated (transaction is rolled back)
- If you need the real database state, use `.reload`
- In tests, always use `.reload` to verify database state after failed updates

## Step 3: Experiment in Rails Console

```bash
rails console
```

Try these commands:

```ruby
# Create a todo
todo = Todo.create!(title: "Learn Rails", completed: false)

# Update using .update
todo.update(title: "Learn Rails and TDD", completed: true)
todo.reload  # Verify changes

# Direct assignment
todo.title = "Just Rails"
todo.changed?  # => true
todo.changes  # => {"title" => ["Learn Rails and TDD", "Just Rails"]}
todo.save

# Check tracking
todo.completed = false
todo.changed_attributes  # => {"completed" => true}
todo.reload

# Update! (strict)
todo.update!(title: "Final title")

# Try invalid update
todo.update(title: "")  # => false (validation fails)
todo.errors.full_messages

exit
```

## Step 3b: Understanding In-Memory vs Database State

This is a critical concept that many developers miss. When an update fails validation:

```ruby
todo = Todo.create!(title: "Task")

# Invalid update
todo.update(title: "")  # Returns false

# The Ruby object is modified in memory
todo.title  # => ""

# But the database still has the old value
todo.reload
todo.title  # => "Task"
```

**This happens because:**
1. Rails updates the object in memory first
2. Then it validates
3. If validation fails, the database transaction is rolled back
4. But the Ruby object still has the in-memory changes

**In tests, this means:**
- After a failed `.update`, use `.reload` to check database state
- Don't rely on the object's in-memory value to verify database persistence
- Always verify what's actually in the database, not what's in memory

This is why the test uses `.reload`:

```ruby
it 'returns false when validation fails' do
  todo = Todo.create!(title: "Task")
  result = todo.update(title: "")

  expect(result).to be(false)
  todo.reload  # Get actual database value
  expect(todo.title).to eq("Task")  # Verify database wasn't changed
end
```

## Step 4: Run All Model Tests

```bash
bundle exec rspec spec/models/
```

Expected: All tests should pass (53 examples total)

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_updates_spec.rb`
- [ ] All `.update` tests passing (6 tests)
- [ ] All `.update!` tests passing (3 tests)
- [ ] All direct assignment tests passing (4 tests)
- [ ] All change tracking tests passing (3 tests)
- [ ] All reload tests passing (2 tests)
- [ ] All model tests passing (55 examples, 0 failures)
- [ ] Experimented in Rails console
- [ ] Verified tests run in VS Code with Better RSpec

## 📝 What You've Learned

- How to update records with `.update`
- How to update with `.update!` (strict version)
- Direct assignment vs `.update`
- How `.save` persists changes
- How validations prevent invalid updates
- **Critical**: In-memory vs database state difference
- **Important**: Failed updates modify object in memory but not database
- How to use `.reload` to sync with database after failed updates
- Change tracking with `.changed?` and `.changes`
- `.changed_attributes` shows what changed
- How to reload from database with `.reload`
- How to verify actual database persistence in tests
- How to handle update errors and validations

## 🔍 Update Methods Quick Reference

| Method | Saves | Returns | Error Handling |
|--------|-------|---------|----------------|
| `.update(...)` | Yes | true/false | Returns false, populates errors |
| `.update!(...)` | Yes | Record | Raises error |
| Direct + `.save` | Yes | true/false | Returns false, populates errors |

## 🚀 Next Lesson

Proceed to **[Lesson 6: Delete Todos](./06_delete_todos.md)** where we'll test deleting todos from the database.

---

**Lesson Status**: ✅ Ready to start
**Time Estimate**: 15-20 minutes
**Difficulty**: Beginner