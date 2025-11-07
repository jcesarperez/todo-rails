# Todo Rails - Tutorial TDD

A step-by-step tutorial project to learn Ruby on Rails using **Test-Driven Development (TDD)** with Rails 7.1.x and Ruby 3.3.x.

## 🎯 Project Goal

Build a complete TODO list web application, writing tests first using TDD methodology.

## 🛠️ Tech Stack

- **Ruby**: 3.3.x
- **Rails**: 7.1.x
- **Database**: SQLite
- **Testing**: RSpec + Rails
- **Editor**: VS Code
- **Environment**: Linux/macOS with zsh or bash

## 📚 How to Use This Project

1. Follow the **[docs/INDEX.md](./docs/INDEX.md)** file for all lessons
2. Each lesson is a separate file in the `docs/` folder
3. Each lesson includes:
   - TDD cycle (Red → Green → Refactor)
   - Code examples
   - Test-first approach
4. Complete the setup checklist below before starting

## ✅ Quick Start

### Prerequisites

- Ruby version manager (`rbenv` or `asdf`)
- `git` installed

### Setup

```bash
# Clone the repository
git clone <repo-url> todo-rails
cd todo-rails

# Install dependencies
bundle install

# Verify everything works
rails --version
ruby --version
bundle exec rspec --version
```

### VS Code Configuration

The project includes a `.vscode/` folder with:
- `settings.json` - Ruby LSP and formatting configuration
- `extensions.json` - Recommended extensions

VS Code will suggest installing the recommended extensions when you open the project.

## ⌨️ Running Tests in VS Code

Use the **Better RSpec** extension to run tests:
- Click the **play icon** next to individual tests in the editor
- Click the **play icon** in the sidebar (Better RSpec panel) to run test files or all tests
- Tests execute directly in VS Code without needing the terminal

## 📁 Project Structure

```
todo-rails/
├── .vscode/              # VS Code configuration
├── app/                  # Rails application code
│   ├── models/           # Data models
│   ├── controllers/      # Controllers
│   ├── views/            # View templates
│   └── ...
├── bin/                  # Executable files (rails, bundler, etc.)
├── config/               # Rails configuration
│   ├── routes.rb
│   ├── database.yml
│   └── ...
├── db/                   # Database
│   ├── migrate/          # Database migrations
│   ├── seeds.rb
│   └── schema.rb
├── lib/                  # Custom library code
├── public/               # Static files (images, CSS, JS)
├── spec/                 # RSpec test files (TDD - we use this)
│   ├── models/
│   ├── controllers/
│   └── ...
├── test/                 # Default Rails test directory (not used in this tutorial)
├── vendor/               # Third-party code
├── config.ru             # Rack configuration
├── Dockerfile            # Docker configuration
├── Gemfile               # Ruby dependencies
├── Gemfile.lock          # Locked gem versions
├── Rakefile              # Rails tasks
├── README.md
├── docs/                 # Tutorial lessons (each lesson is a separate file)
│   ├── INDEX.md          # Tutorial index and navigation
│   ├── 01_environment_setup.md
│   ├── 02_generate_todo_model.md
│   ├── 03_create_todos.md
│   └── ...
└── .gitignore
```

## 🎓 Resources

- [Rails Guides](https://guides.rubyonrails.org)
- [RSpec Documentation](https://rspec.info)
- [Ruby on Rails API](https://api.rubyonrails.org)
- [Better Specs](https://www.betterspecs.org) - RSpec best practices
- [Ruby LSP](https://shopify.github.io/ruby-lsp/) - Official Ruby Language Server

## 📖 Next Steps

Start with **[TUTORIAL.md](./TUTORIAL.md)** - Lesson 1: Environment Setup

---

**Created**: November 2025
**Goal**: Learn Ruby on Rails with TDD
**Level**: Beginner