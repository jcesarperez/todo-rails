# Lesson 4: List Todos

**Objective**: Test retrieving todos from the database using different query methods.

**What we'll build**: Methods to list all todos, count them, and filter by conditions.

## Understanding Query Methods

Rails provides several ways to retrieve records:

- **`.all`** - Returns all records as an array
- **`.count`** - Returns the number of records
- **`.first`** - Returns the first record
- **`.last`** - Returns the last record
- **`.find(id)`** - Returns record by ID (raises error if not found)
- **`.find_by(attribute: value)`** - Returns first match or nil
- **`.where(conditions)`** - Returns filtered records

## Step 1: Write Tests for Listing Todos (Red Phase)

Create a new spec file for querying todos:

```bash
touch spec/models/todo_queries_spec.rb
```

Edit `spec/models/todo_queries_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe '.all' do
    it 'returns all todos' do
      todo1 = Todo.create!(title: "Task 1")
      todo2 = Todo.create!(title: "Task 2")
      todo3 = Todo.create!(title: "Task 3")

      all_todos = Todo.all
      expect(all_todos.length).to eq(3)
      expect(all_todos).to include(todo1, todo2, todo3)
    end

    it 'returns empty array when no todos exist' do
      todos = Todo.all
      expect(todos).to be_empty
    end
  end

  describe '.count' do
    it 'returns the number of todos' do
      Todo.create!(title: "Task 1")
      Todo.create!(title: "Task 2")

      expect(Todo.count).to eq(2)
    end

    it 'returns 0 when no todos exist' do
      expect(Todo.count).to eq(0)
    end
  end

  describe '.first and .last' do
    it 'returns the first todo' do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")

      expect(Todo.first).to eq(todo1)
    end

    it 'returns the last todo' do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")

      expect(Todo.last).to eq(todo2)
    end

    it 'returns nil when no todos exist' do
      expect(Todo.first).to be_nil
      expect(Todo.last).to be_nil
    end
  end

  describe '.find' do
    it 'finds a todo by id' do
      todo = Todo.create!(title: "Find me")
      found = Todo.find(todo.id)

      expect(found).to eq(todo)
    end

    it 'raises RecordNotFound when todo does not exist' do
      expect {
        Todo.find(999)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '.find_by' do
    it 'finds a todo by title' do
      todo = Todo.create!(title: "Specific Task")
      found = Todo.find_by(title: "Specific Task")

      expect(found).to eq(todo)
    end

    it 'returns nil when no match found' do
      found = Todo.find_by(title: "Non-existent")

      expect(found).to be_nil
    end

    it 'finds a todo by completed status' do
      completed_todo = Todo.create!(title: "Done", completed: true)
      incomplete_todo = Todo.create!(title: "Not done", completed: false)

      found = Todo.find_by(completed: true)
      expect(found).to eq(completed_todo)
    end
  end

  describe '.where' do
    it 'returns todos matching a condition' do
      completed1 = Todo.create!(title: "Task 1", completed: true)
      completed2 = Todo.create!(title: "Task 2", completed: true)
      incomplete = Todo.create!(title: "Task 3", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos.length).to eq(2)
      expect(completed_todos).to include(completed1, completed2)
    end

    it 'returns empty array when no matches found' do
      Todo.create!(title: "Task", completed: false)

      completed_todos = Todo.where(completed: true).to_a
      expect(completed_todos).to be_empty
    end

    it 'filters by multiple conditions' do
      todo1 = Todo.create!(title: "Buy milk", completed: true)
      todo2 = Todo.create!(title: "Buy milk", completed: false)
      todo3 = Todo.create!(title: "Walk dog", completed: true)

      results = Todo.where(title: "Buy milk", completed: true).to_a
      expect(results.length).to eq(1)
      expect(results.first).to eq(todo1)
    end
  end

  describe 'ordering' do
    it 'returns todos ordered by created_at ascending' do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")
      todo3 = Todo.create!(title: "Third")

      ordered = Todo.order(:created_at).to_a
      expect(ordered).to eq([todo1, todo2, todo3])
    end

    it 'returns todos ordered by created_at descending' do
      todo1 = Todo.create!(title: "First")
      todo2 = Todo.create!(title: "Second")
      todo3 = Todo.create!(title: "Third")

      ordered = Todo.order(created_at: :desc).to_a
      expect(ordered).to eq([todo3, todo2, todo1])
    end

    it 'combines where and order' do
      incomplete1 = Todo.create!(title: "Task 1", completed: false)
      completed1 = Todo.create!(title: "Task 2", completed: true)
      incomplete2 = Todo.create!(title: "Task 3", completed: false)

      incomplete_ordered = Todo.where(completed: false).order(created_at: :desc).to_a
      expect(incomplete_ordered).to eq([incomplete2, incomplete1])
    end
  end
end
```

Run the tests to see them pass:

```bash
bundle exec rspec spec/models/todo_queries_spec.rb
```

Expected output:

```
Todo
  .all
    returns all todos
    returns empty array when no todos exist
  .count
    returns the number of todos
    returns 0 when no todos exist
  .first and .last
    returns the first todo
    returns the last todo
    returns nil when no todos exist
  .find
    finds a todo by id
    raises RecordNotFound when todo does not exist
  .find_by
    finds a todo by title
    returns nil when no match found
    finds a todo by completed status
  .where
    returns todos matching a condition
    returns empty array when no matches found
    filters by multiple conditions
  ordering
    returns todos ordered by created_at ascending
    returns todos ordered by created_at descending
    combines where and order

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
18 examples, 0 failures
```

Perfect! All tests pass because Rails ActiveRecord provides these methods automatically. ✓ This is the **Green** phase.

## Step 2: Understanding What We Tested

**`.all`:**
- ✅ Returns all records as an array
- ✅ Returns empty array when no records exist

**`.count`:**
- ✅ Returns number of records
- ✅ More efficient than `.all.length` for large datasets

**`.first` and `.last`:**
- ✅ Returns first/last record
- ✅ Returns nil when no records exist

**`.find(id)`:**
- ✅ Gets record by primary key
- ✅ Raises `RecordNotFound` if ID doesn't exist
- ✅ Use when you're sure the record exists

**`.find_by(conditions)`:**
- ✅ Finds first record matching conditions
- ✅ Returns nil if not found (safe)
- ✅ Works with any attribute

**`.where(conditions)`:**
- ✅ Returns all records matching conditions
- ✅ Can filter by multiple conditions
- ✅ Returns empty array if no matches

**`.order()`:**
- ✅ Orders results ascending by default
- ✅ Use `:desc` for descending order
- ✅ Can be chained with `.where()`

## Understanding ActiveRecord::Relation

This is important to understand:

**`.where()`, `.order()`, and other query methods return a `Relation` object, NOT an array.**

```ruby
# This is a Relation (lazy query, not executed yet)
result = Todo.where(completed: true)
result.class  # => Todo::ActiveRecord_Relation

# This is an Array (query executed, results materialized)
result = Todo.where(completed: true).to_a
result.class  # => Array
```

**Why does this matter?**

1. **Lazy evaluation**: The query isn't executed until you convert it to an array or iterate over it
2. **Memory efficient**: For large datasets, you don't load everything into memory
3. **Chainable**: You can keep adding filters before executing

**When do you need `.to_a`?**

- When you need **guaranteed array behavior**
- When you're **comparing equality**: `expect(result).to eq([todo1, todo2])`
- When you want to **preserve order exactly**
- When testing, for **clarity and consistency**

**Example:**

```ruby
# Without .to_a (Relation object)
result = Todo.where(completed: true)
result == [todo1, todo2]  # May return false (comparing Relation to Array)

# With .to_a (real Array)
result = Todo.where(completed: true).to_a
result == [todo1, todo2]  # Returns true (comparing Array to Array)
```

**In our tests**, we use `.to_a` on `.where()` and `.order()` to ensure we're always working with actual arrays, making our assertions more reliable.

## Step 3: Experiment in Rails Console

```bash
rails console
```

Try these commands:

```ruby
# Create some test data
t1 = Todo.create!(title: "Learn Rails", completed: true)
t2 = Todo.create!(title: "Build app", completed: false)
t3 = Todo.create!(title: "Deploy", completed: false)

# List all
Todo.all
Todo.count

# Get first/last
Todo.first
Todo.last

# Find by ID
Todo.find(t1.id)

# Find by attribute
Todo.find_by(title: "Build app")
Todo.find_by(completed: true)

# Where with conditions
Todo.where(completed: false)
Todo.where(completed: false).count

# Order results
Todo.order(:created_at)
Todo.order(created_at: :desc)

# Chain methods
Todo.where(completed: false).order(:title)

exit
```

## Step 4: Run All Model Tests

```bash
bundle exec rspec spec/models/
```

Expected: All tests should pass (34 examples total)

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_queries_spec.rb`
- [ ] All `.all` tests passing (2 tests)
- [ ] All `.count` tests passing (2 tests)
- [ ] All `.first` and `.last` tests passing (3 tests)
- [ ] All `.find` tests passing (2 tests)
- [ ] All `.find_by` tests passing (3 tests)
- [ ] All `.where` tests passing (3 tests)
- [ ] All ordering tests passing (3 tests)
- [ ] All model tests passing (34 examples, 0 failures)
- [ ] Experimented in Rails console
- [ ] Verified tests run in VS Code with Better RSpec

## 📝 What You've Learned

- How to retrieve all records with `.all`
- How to count records with `.count`
- How to get first/last records
- How to find by ID with `.find`
- How to find by attribute with `.find_by`
- How to filter records with `.where`
- How to order results
- How to chain query methods
- Difference between `.find` (strict) and `.find_by` (safe)
- How to work with query results in Rails console

## 🔍 Key Query Methods Reference

| Method | Returns | Type | Notes |
|--------|---------|------|-------|
| `.all` | Records | Array | Always an array |
| `.count` | Integer | Integer | Efficient count |
| `.first` | Record or nil | Record/nil | Returns single record |
| `.last` | Record or nil | Record/nil | Returns single record |
| `.find(id)` | Record | Record | Raises if not found |
| `.find_by(...)` | Record or nil | Record/nil | Safe, returns nil |
| `.where(...)` | Records | Relation | Call `.to_a` for array |
| `.order(...)` | Records | Relation | Call `.to_a` for array |

**Relation vs Array:**
- `Relation`: Lazy-evaluated query object, chainable, memory-efficient
- `Array`: Materialized results, immediately available
- Use `.to_a` to convert `Relation` to `Array` when needed

## 🚀 Next Lesson

Proceed to **[Lesson 5: Update Todos](./05_update_todos.md)** where we'll test updating todo attributes.

---

**Lesson Status**: ✅ Ready to start
**Time Estimate**: 15-20 minutes
**Difficulty**: Beginner