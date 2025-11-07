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

    it 'has timestamps' do
      todo = Todo.create!(title: "Learn Rails")
      expect(todo.id).not_to be_nil
      expect(todo.created_at).not_to be_nil
      expect(todo.updated_at).not_to be_nil
    end

    it 'created_at and updated_at are initially the same' do
      todo = Todo.create!(title: "Learn Rails")
      expect(todo.created_at).to eq(todo.updated_at)
    end
  end
end
```

**What changed:**
- Added test for `id` - Should exist after saving to database
- Added test for `created_at` and `updated_at` - Should be set automatically
- Added test that both timestamps are initially the same

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

Now we generate the model to make the tests pass. **Important**: Use `--skip-test` because we already wrote our own spec and don't want Rails to overwrite it:

```bash
rails generate model Todo title:string completed:boolean --skip-test
```

This command:
- Creates `app/models/todo.rb`
- Creates a migration file `db/migrate/[timestamp]_create_todos.rb`
- **Does NOT** overwrite our existing spec (because of `--skip-test`)

**Why `--skip-test`?**
- We already wrote `spec/models/todo_spec.rb` with real tests
- Rails would generate an empty placeholder spec if we didn't use this flag
- We want to keep our TDD tests, not replace them

### Update the Migration with Default Value

The generated migration needs to set a default value for `completed`. Open the migration file `db/migrate/[timestamp]_create_todos.rb` and modify it:

```ruby
class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.boolean :completed, default: false

      t.timestamps
    end
  end
end
```

**Why `default: false`?**
- Our test expects `completed` to default to `false`, not `nil`
- This is set at the database level, so all new todos automatically have this value

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
    has timestamps
    created_at and updated_at are initially the same

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
5 examples, 0 failures
```

Great! All tests pass. ✓ This is the **Green** phase.

## Step 4: Install Annotate Models (Optional but Recommended)

The `annotate_models` gem automatically adds schema comments to your models, making it clear what attributes each model has:

```bash
bundle add annotate --group development
```

Generate annotations:

```bash
rails generate annotate:install
bundle exec annotate
```

This will update `app/models/todo.rb` to look like this:

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
end
```

Now it's clear what attributes the model has just by looking at the code!

## Step 5: Refactor (Optional)

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
- Validators like `validates :title, presence: true` ensure data integrity
- Schema annotations document what attributes it has

**Migration**: Defines database schema
- Creates/modifies tables
- Is version controlled (can undo with `rails db:rollback`)
- Runs in order
- `default: false` sets default values at the database level

**Spec**: Tests the model behavior
- Uses RSpec syntax (describe, it, expect)
- Uses Shoulda Matchers for elegant assertions (`validate_presence_of`)
- Tests validations
- Tests attributes and defaults

**Shoulda Matchers**: Provides readable matchers for Rails testing
- `validate_presence_of(:title)` - Tests presence validation
- Makes assertions more natural and readable
- Works seamlessly with RSpec

**Annotate Models**: Automatically documents model attributes
- Adds schema information as comments to models
- Makes it immediately clear what attributes exist
- Updates when migrations change

## 🎯 Completion Checklist

- [ ] Created `spec/models/todo_spec.rb` with all attribute tests
- [ ] Generated Todo model with `rails generate model` and `--skip-test`
- [ ] Updated migration with `default: false`
- [ ] Ran `rails db:create` and `rails db:migrate`
- [ ] Added `:presence` validation to title
- [ ] Installed and ran `annotate_models`
- [ ] All tests passing (5 examples, 0 failures)
- [ ] Verified tests run in VS Code with Better RSpec

## 📝 What You've Learned

- How to write specs before code (Red phase)
- How to generate Rails models with `--skip-test`
- How to create and run database migrations
- How to set default values in migrations
- How to add validations to models
- How to make failing tests pass (Green phase)
- How to document models with annotate_models
- The TDD cycle in action

## 🚀 Next Lesson

Proceed to **[Lesson 3: Create Todos](./03_create_todos.md)** where we'll test creating new todos and persist them to the database.

---

**Lesson Status**: ✅ Ready to start
**Time Estimate**: 20-30 minutes
**Difficulty**: Beginner