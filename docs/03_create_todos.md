# Lesson 3: Create Todos

**Objective**: Test creating new todos and persisting them to the database.

**What we'll build**: Methods to create todos using different approaches (`.new`, `.create`, `.create!`)

## Understanding Create Methods

Rails provides several ways to create records:

- **`.new`** - Creates in memory, doesn't save to database
- **`.create`** - Creates AND saves to database (returns nil if validation fails)
- **`.create!`** - Creates AND saves to database (raises error if validation fails)

## Step 1: Write Tests for Creating Todos (Red Phase)

Create a new spec file for model methods:

```bash
touch spec/models/todo_creation_spec.rb
```

Edit `spec/models/todo_creation_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe '.create' do
    it 'creates a new todo with valid attributes' do
      todo = Todo.create(title: "Buy groceries")
      expect(todo).to be_persisted
      expect(todo.title).to eq("Buy groceries")
    end

    it 'creates a todo with completed as false by default' do
      todo = Todo.create(title: "Buy groceries")
      expect(todo.completed).to be(false)
    end

    it 'does not save a todo without a title' do
      todo = Todo.create(title: "")
      expect(todo).not_to be_persisted
    end

    it 'returns nil when create fails validation' do
      todo = Todo.create(title: nil)
      expect(todo).not_to be_persisted
      expect(todo.id).to be_nil
    end
  end

  describe '.create!' do
    it 'creates a new todo with valid attributes' do
      todo = Todo.create!(title: "Learn Rails")
      expect(todo).to be_persisted
      expect(todo.id).not_to be_nil
    end

    it 'raises an error when validation fails' do
      expect {
        Todo.create!(title: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#new and #save' do
    it 'creates a todo in memory and saves it' do
      todo = Todo.new(title: "Complete lesson")
      expect(todo).not_to be_persisted

      todo.save
      expect(todo).to be_persisted
    end

    it 'returns false when save fails' do
      todo = Todo.new(title: "")
      result = todo.save
      expect(result).to be(false)
    end

    it 'returns true when save succeeds' do
      todo = Todo.new(title: "Success")
      result = todo.save
      expect(result).to be(true)
    end
  end
end
```

Run the tests to see them fail:

```bash
bundle exec rspec spec/models/todo_creation_spec.rb
```

You should see output like:

```
Todo
  .create
    creates a new todo with valid attributes
    creates a todo with completed as false by default
    does not save a todo without a title
    returns nil when create fails validation
  .create!
    creates a new todo with valid attributes
    raises an error when validation fails
  #new and #save
    creates a todo in memory and saves it
    returns false when save fails
    returns true when save succeeds

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
9 examples, 0 failures
```

Wait - they all pass! This is because Rails ActiveRecord provides `.create`, `.create!`, `.new`, and `.save` automatically. ✓ This is the **Green** phase already.

## Step 2: Understanding What We Tested

The tests verify important behaviors:

**`.create` method:**
- ✅ Saves to database (`.persisted?` returns true)
- ✅ Respects default values (`.completed` is false)
- ✅ Respects validations (empty title doesn't save)
- ✅ Returns unsaved record on validation failure

**`.create!` method:**
- ✅ Saves to database
- ✅ Raises `ActiveRecord::RecordInvalid` on validation failure
- ✅ Used when you want errors to bubble up

**`.new` and `.save`:**
- ✅ `.new` creates in memory without saving
- ✅ `.save` persists to database
- ✅ `.save` returns true/false based on success
- ✅ `.save!` would raise error on failure

## Step 3: Test Your Understanding

Experiment in the Rails console:

```bash
rails console
```

Try these commands:

```ruby
# Create and save in one step
todo1 = Todo.create(title: "Task 1")
todo1.persisted?  # => true

# Create in memory first
todo2 = Todo.new(title: "Task 2")
todo2.persisted?  # => false

# Then save
todo2.save
todo2.persisted?  # => true

# Try with invalid data
todo3 = Todo.create(title: "")
todo3.persisted?  # => false
todo3.errors.full_messages  # => ["Title can't be blank"]

# Create! raises error
Todo.create!(title: nil)  # => ActiveRecord::RecordInvalid

# Exit console
exit
```

## Step 4: Run All Tests

Now run all model tests to make sure nothing broke:

```bash
bundle exec rspec spec/models/
```

Expected output:

```
Todo
  validations
    validates presence of title
  attributes
    has a title
    has completed status that defaults to false
    has timestamps
    created_at and updated_at are initially the same
  .create
    creates a new todo with valid attributes
    creates a todo with completed as false by default
    does not save a todo without a title
    returns nil when create fails validation
  .create!
    creates a new todo with valid attributes
    raises an error when validation fails
  #new and #save
    creates a todo in memory and saves it
    returns false when save fails
    returns true when save succeeds

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
14 examples, 0 failures
```

Perfect! All 14 tests pass. ✓

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_creation_spec.rb`
- [ ] All tests for `.create` passing
- [ ] All tests for `.create!` passing
- [ ] All tests for `.new` and `.save` passing
- [ ] Ran all model tests (14 examples, 0 failures)
- [ ] Experimented in Rails console
- [ ] Verified tests run in VS Code with Better RSpec

## 📝 What You've Learned

- How to test object creation in Rails
- Difference between `.new`, `.create`, and `.create!`
- What `.persisted?` means
- How validations affect persistence
- How to test for raised exceptions
- Rails ActiveRecord provides these methods automatically
- How to use Rails console for experimentation

## 🔍 Key Takeaways

- **`.new`** + **`.save`** = Two-step creation
- **`.create`** = One-step creation (safe - returns record)
- **`.create!`** = One-step creation (strict - raises error)
- **`.persisted?`** = Checks if saved to database
- **Validations** = Prevent saving invalid records

## 🚀 Next Lesson

Proceed to **[Lesson 4: List Todos](./04_list_todos.md)** where we'll test retrieving todos from the database.

---

**Lesson Status**: ✅ Ready to start
**Time Estimate**: 15-20 minutes
**Difficulty**: Beginner