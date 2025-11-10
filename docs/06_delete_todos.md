# Lesson 6: Delete Todos

**Objective**: Test deleting todos from the database.

**What we'll build**: Methods to delete todos and verify they're removed.

## Understanding Delete Methods

Rails provides several ways to delete records:

- **`.destroy`** - Deletes the record from database
- **`.destroy!`** - Deletes and returns the record (or raises error)
- **`.delete`** - Fast delete without callbacks
- **`.delete_all`** - Delete multiple records at once

## Step 1: Write Tests for Deleting Todos (Red Phase)

Create a new spec file for deleting todos:

```bash
touch spec/models/todo_destroys_spec.rb
```

Edit `spec/models/todo_destroys_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe '.destroy' do
    it 'removes a todo from the database' do
      todo = Todo.create!(title: "Delete me")
      todo_id = todo.id

      result = todo.destroy

      expect(Todo.find_by(id: todo_id)).to be_nil
    end

    it 'returns the destroyed record' do
      todo = Todo.create!(title: "Delete me")
      result = todo.destroy

      expect(result).to eq(todo)
    end

    it 'marks record as not persisted after destroy' do
      todo = Todo.create!(title: "Delete me")
      todo.destroy

      expect(todo.persisted?).to be(false)
    end

    it 'destroys multiple todos' do
      todo1 = Todo.create!(title: "Task 1")
      todo2 = Todo.create!(title: "Task 2")
      todo3 = Todo.create!(title: "Task 3")

      todo1.destroy
      todo2.destroy

      expect(Todo.count).to eq(1)
      expect(Todo.first).to eq(todo3)
    end

    it 'can destroy from find result' do
      todo = Todo.create!(title: "Task")
      found = Todo.find(todo.id)

      found.destroy

      expect(Todo.find_by(id: todo.id)).to be_nil
    end
  end

  describe '.delete' do
    it 'removes a todo from the database' do
      todo = Todo.create!(title: "Delete me")
      todo_id = todo.id

      todo.delete

      expect(Todo.find_by(id: todo_id)).to be_nil
    end

    it 'returns the deleted record' do
      todo = Todo.create!(title: "Delete me")
      result = todo.delete

      expect(result).to eq(todo)
    end

    it 'is faster than destroy (no callbacks)' do
      todo = Todo.create!(title: "Task")
      
      # Delete doesn't trigger callbacks, just removes from DB
      expect(Todo.count).to eq(1)
      result = todo.delete
      expect(result).to eq(todo)  # Returns the deleted record
      expect(Todo.count).to eq(0)
    end
  end

  describe '.delete_all' do
    it 'deletes all records' do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")
      Todo.create!(title: "Task 3")

      Todo.delete_all

      expect(Todo.count).to eq(0)
    end

    it 'returns the number of records deleted' do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")

      result = Todo.delete_all

      expect(result).to eq(2)
    end

    it 'can delete with conditions' do
      completed1 = Todo.create!(title: "Task 1", completed: true)
      completed2 = Todo.create!(title: "Task 2", completed: true)
      incomplete = Todo.create!(title: "Task 3", completed: false)

      Todo.where(completed: true).delete_all

      expect(Todo.count).to eq(1)
      expect(Todo.first).to eq(incomplete)
    end
  end

  describe 'destroy vs delete' do
    it 'destroy returns the record' do
      todo = Todo.create!(title: "Task")
      destroyed = todo.destroy

      expect(destroyed).to eq(todo)
    end

    it 'delete returns the record' do
      todo = Todo.create!(title: "Task")
      deleted = todo.delete

      expect(deleted).to eq(todo)
    end

    it 'both remove the record from database' do
      todo1 = Todo.create!(title: "Task 1")
      todo2 = Todo.create!(title: "Task 2")

      todo1.destroy
      todo2.delete

      expect(Todo.count).to eq(0)
    end
  end

  describe 'edge cases' do
    it 'does not raise error when destroying non-existent ID' do
      todo = Todo.create!(title: "Task")
      todo.destroy

      expect {
        # Trying to destroy an already destroyed record
        todo.destroy
      }.not_to raise_error
    end

    it 'find raises error but find_by returns nil' do
      todo = Todo.create!(title: "Task")
      todo_id = todo.id
      todo.destroy

      expect {
        Todo.find(todo_id)
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Todo.find_by(id: todo_id)).to be_nil
    end

    it 'verifies deletion with count' do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")

      expect(Todo.count).to eq(2)

      Todo.destroy_all

      expect(Todo.count).to eq(0)
    end
  end
end
```

Run the tests to see them pass:

```bash
bundle exec rspec spec/models/todo_destroys_spec.rb
```

Expected output:

```
Todo
  .destroy
    removes a todo from the database
    returns the destroyed record
    marks record as not persisted after destroy
    destroys multiple todos
    can destroy from find result
  .delete
    removes a todo from the database
    returns the deleted record
    is faster than destroy (no callbacks)
  .delete_all
    deletes all records
    returns the number of records deleted
    can delete with conditions
  destroy vs delete
    destroy returns the record
    delete returns the record
    both remove the record from database
  edge cases
    does not raise error when destroying non-existent ID
    find raises error but find_by returns nil
    verifies deletion with count

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
19 examples, 0 failures
```

Perfect! All tests pass because Rails ActiveRecord provides these methods automatically. ✓ This is the **Green** phase.

## Step 2: Understanding What We Tested

**`.destroy`:**
- ✅ Removes record from database
- ✅ Returns the destroyed record
- ✅ Sets `persisted?` to false
- ✅ Can be used after finding a record
- ✅ Safe and commonly used

**`.delete`:**
- ✅ Removes record from database faster than destroy
- ✅ Returns the deleted record (on a single record)
- ✅ Skips Rails callbacks (if you had any)
- ✅ More efficient for bulk deletes
- ✅ On single records, behaves similarly to `.destroy`

**`.delete_all`:**
- ✅ Deletes all records matching conditions
- ✅ Returns the count of deleted records (integer)
- ✅ Can be chained with `.where()`
- ✅ Equivalent to `.destroy_all` but faster

**Key difference:** 
- `.delete` on a single record returns the record
- `.delete_all` on multiple records returns the count

**Edge cases:**
- ✅ Can destroy an already destroyed record (no error)
- ✅ `.find` raises error for deleted records
- ✅ `.find_by` returns nil for deleted records
- ✅ `.count` reflects deletions immediately

## Step 3: Experiment in Rails Console

```bash
rails console
```

Try these commands:

```ruby
# Create test data
t1 = Todo.create!(title: "Task 1")
t2 = Todo.create!(title: "Task 2")
t3 = Todo.create!(title: "Task 3", completed: true)

# Destroy single record
t1.destroy
Todo.count  # => 2

# Delete single record
t2.delete
Todo.count  # => 1

# Delete all
Todo.delete_all
Todo.count  # => 0

# Create for more tests
t1 = Todo.create!(title: "Task 1", completed: true)
t2 = Todo.create!(title: "Task 2", completed: false)
t3 = Todo.create!(title: "Task 3", completed: true)

# Conditional delete
Todo.where(completed: true).delete_all
Todo.count  # => 1

# Verify what's left
Todo.first.title  # => "Task 2"

exit
```

## Step 4: Run All Model Tests

```bash
bundle exec rspec spec/models/
```

Expected: All tests should pass (72 examples total)

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_destroys_spec.rb`
- [ ] All `.destroy` tests passing (5 tests)
- [ ] All `.delete` tests passing (3 tests)
- [ ] All `.delete_all` tests passing (3 tests)
- [ ] All destroy vs delete tests passing (3 tests)
- [ ] All edge case tests passing (3 tests)
- [ ] All model tests passing (72 examples, 0 failures)
- [ ] Experimented in Rails console
- [ ] Verified tests run in VS Code with Better RSpec

## 📝 What You've Learned

- How to destroy records with `.destroy` (returns record)
- How to delete records with `.delete` (returns record, faster)
- How to delete multiple records with `.delete_all` (returns count)
- Difference between `.destroy` (with callbacks) and `.delete` (without callbacks)
- `.delete` on single record behaves like `.destroy` but faster
- `.delete_all` returns count of deleted records
- How to verify deletion with `.find_by`
- How `.find` raises error vs `.find_by` returns nil
- How to chain `.where()` with `.delete_all`
- Destructive operations and their side effects
- Edge cases with already-deleted records
- How to check if record is persisted after deletion

## 🔍 Delete Methods Quick Reference

| Method | Returns | Effect | Use Case |
|--------|---------|--------|----------|
| `.destroy` | Record | Removes from DB | Safe, commonly used |
| `.delete` | Record | Fast remove, no callbacks | Single record deletion |
| `.delete_all` | Integer (count) | Removes all matching | Batch deletions |
| `.destroy_all` | Array | Removes all matching | With callbacks |

## 🚀 Next Lesson

Proceed to **[Lesson 7: Mark as Completed](./07_mark_as_completed.md)** where we'll test toggling the completed status of todos.

---

**Lesson Status**: ✅ Ready to start
**Time Estimate**: 15-20 minutes
**Difficulty**: Beginner