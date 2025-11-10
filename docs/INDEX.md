# Todo Rails - Tutorial Index

Complete step-by-step guide to building a TODO list application with Ruby on Rails using Test-Driven Development (TDD).

## 📚 Lessons

### Fundamentals
- **[Lesson 1: Environment Setup](./01_environment_setup.md)** ✅
  - Install Ruby, Rails, RSpec
  - Configure VS Code
  - Verify everything works

- **[Lesson 2: Generate Todo Model](./02_generate_todo_model.md)** ✅
  - Create Todo model with TDD
  - Add validations
  - Run migrations

### CRUD Operations
- **[Lesson 3: Create Todos](./03_create_todos.md)** ✅
  - Test creating todos
  - Persist to database

- **[Lesson 4: List Todos](./04_list_todos.md)** ✅
  - Test fetching all todos
  - Query database

- **[Lesson 5: Update Todos](./05_update_todos.md)** ✅
  - Test updating todo attributes
  - Validate changes

- **[Lesson 6: Delete Todos](./06_delete_todos.md)** ✅
  - Test deleting todos
  - Handle edge cases

- **[Lesson 7: Mark as Completed](./07_mark_as_completed.md)** (coming soon)
  - Test completion toggle
  - Update status

### Controllers & Views
- **[Lesson 8: Views and Controllers](./08_views_and_controllers.md)** (coming soon)
  - Create Rails controllers
  - Build HTML views
  - Test request specs

## 🎯 Learning Path

1. **Start here**: [Lesson 1: Environment Setup](./01_environment_setup.md)
2. **Follow sequentially** - Each lesson builds on the previous
3. **Complete all tests** before moving to the next lesson
4. **Use Better RSpec** in VS Code to run tests

## 🔄 TDD Workflow

Every lesson follows this cycle:

```
🔴 Red   → Write failing test
🟢 Green → Write code to pass test
🔵 Refactor → Improve code quality
```

## 💡 Tips

- **Run tests frequently** - `bundle exec rspec` after each change
- **Read error messages** - They guide you to the solution
- **Keep tests simple** - One assertion per test when possible
- **Use Better RSpec** - Click play icon in sidebar to run tests
- **Ignore Ruby LSP errors** - If you see test errors from Ruby LSP, they're normal. Better RSpec handles the testing.

## 📖 Prerequisites

- Completed [Lesson 1: Environment Setup](./01_environment_setup.md)
- Ruby 3.3.x and Rails 7.1.x installed
- VS Code with extensions configured
- Basic understanding of Ruby syntax

## 🎓 What You'll Learn

- Test-Driven Development (TDD) fundamentals
- Rails model, controller, and view architecture
- RSpec testing framework
- Database migrations and validations
- RESTful API principles
- Web development best practices

## 📞 Troubleshooting

**Tests not running?**
- Verify: `bundle exec rspec --version`
- Check: `rails db:migrate`

**Better RSpec not showing?**
- Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window"
- Check extensions are installed

**Seeing errors in Test Results from Ruby LSP?**
- This is normal. We use Better RSpec for testing.
- Ignore these errors and use Better RSpec's sidebar instead.
- Ensure `rubyLsp.testExplorer: false` and `rubyLsp.enableTestLogs: false` in settings.json

**Database errors?**
- Reset database: `rails db:drop db:create db:migrate`

## ⏱️ Time Estimates

| Lesson | Time | Difficulty |
|--------|------|-----------|
| 1. Setup | 30-45 min | Beginner |
| 2. Model | 20-30 min | Beginner |
| 3. Create | 15-20 min | Beginner |
| 4. List | 15-20 min | Beginner |
| 5. Update | 15-20 min | Beginner |
| 6. Delete | 15-20 min | Beginner |
| 7. Completed | 15-20 min | Beginner |
| 8. Views | 30-40 min | Intermediate |

**Total**: ~4-5 hours for complete tutorial

---

**Ready to start?** → Go to [Lesson 1: Environment Setup](./01_environment_setup.md)