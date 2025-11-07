# Lesson 2: Generate Todo Model

**Objective**: Create the `Todo` model using TDD. We'll write tests first, then generate the model and make them pass.

**What we'll build**: A Todo model with basic attributes and validations.

## Understanding the TDD Cycle

Before we start, remember the TDD cycle:

1. **🔴 Red** - Write a test that fails
2. **🟢 Green** - Write minimal code to pass the test
3. **🔵 Refactor** - Improve code without breaking tests

## Step 1: Create the Todo Model Spec (Red Phase)

First, we delete the smoke test:

```bash
rm spec/models/smoke_test_spec.rb
```

Now create the spec file for our Todo model:

```bash
touch spec/models/todo_spec.rb
```

Edit `spec/models/todo_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Todo, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'attributes' do
    it 'has a title' do
      todo = Todo.new(title: "Learn Rails")
      expect(todo.title).to eq("Learn Rails")
    end

    it 'has completed status that defaults to false' do
      todo = Todo.new(title: "Learn Rails")
      expect(todo.completed).to be(false)
    end
  end
end
```

Run the test to see it fail:

```bash
bundle exec rspec spec/models/todo_spec.rb
```

You should see errors like:
```
uninitialized constant Todo (NameError)
```

This is expected! We haven't created the model yet. ✓ This is the **Red** phase.

## Step 2: Generate the Todo Model (Green Phase)

Now we generate the model to make the tests pass:

```bash
rails generate model Todo title:string completed:boolean
```

This command:
- Creates `app/models/todo.rb`
- Creates a migration file `db/migrate/[timestamp]_create_todos.rb`
- Creates the model spec (which we already have)

Let's look at what was generated in `app/models/todo.rb`:

```ruby
class Todo < ApplicationRecord
end
```

And the migration in `db/migrate/[timestamp]_create_todos.rb`:

```ruby
class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.boolean :completed

      t.timestamps
    end
  end
end
```

Now create the test database and run migrations:

```bash
rails db:create
rails db:migrate
```

Run the tests again:

```bash
bundle exec rspec spec/models/todo_spec.rb
```

You might see this error:

```
Failure/Error: it { is_expected.to validate_presence_of(:title) }
  Expected Todo to validate :title
```

This is because we haven't added the validation yet. Let's add it.

## Step 3: Add Validations (Green Phase)

Edit `app/models/todo.rb`:

```ruby
class Todo < ApplicationRecord
  validates :title, presence: true
end
```

Run the tests again:

```bash
bundle exec rspec spec/models/todo_spec.rb
```

Expected output:

```
Todo
  validations
    validates presence of title
  attributes
    has a title
    has completed status that defaults to false

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
3 examples, 0 failures
```

Great! All tests pass. ✓ This is the **Green** phase.

## Step 4: Refactor (Optional)

Our code is already simple, so there's not much to refactor. But let's review:

- The model is clean and minimal
- Validations are clear
- Tests are readable

In real projects, this is where you'd improve code quality, extract methods, etc.

## Step 5: Verify with Better RSpec

Open `spec/models/todo_spec.rb` in VS Code and:
1. Click the play icon next to each test to run them individually
2. Click the play icon in the Better RSpec sidebar to run all tests

All should pass ✓

## Understanding What We Did

**Model**: A Rails model is a class that represents data in your application
- Inherits from `ApplicationRecord`
- Maps to a database table (`todos`)
- Contains business logic and validations

**Migration**: Defines database schema
- Creates/modifies tables
- Is version controlled (can undo with `rails db:rollback`)
- Runs in order

**Spec**: Tests the model behavior
- Uses RSpec syntax (describe, it, expect)
- Tests validations
- Tests attributes

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_spec.rb`
- [ ] Generated Todo model with `rails generate model`
- [ ] Ran `rails db:create` and `rails db:migrate`
- [ ] Added `:presence` validation to title
- [ ] All tests passing (3 examples, 0 failures)
- [ ] Verified tests run in VS Code with Better RSpec

## 📝 What You've Learned

- How to write specs before code (Red phase)
- How to generate Rails models
- How to create and run database migrations
- How to add validations to models
- How to make failing tests pass (Green phase)
- The TDD cycle in action

## 🚀 Next Lesson

Proceed to **[Lesson 3: Create Todos](./03_create_todos.md)** where we'll test creating new todos and persist them to the database.

---

**Lesson Status**: ✅ Ready to start
**Time Estimate**: 20-30 minutes
**Difficulty**: Beginner