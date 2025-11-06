# Todo Rails - Tutorial TDD

A step-by-step tutorial project to learn Ruby on Rails using **Test-Driven Development (TDD)** with Rails 7.1.x and Ruby 3.3.x.

The goal is to build a complete TODO list web application, from scratch, writing tests first.

## 🎯 Project Goal

Create a task management web application (TODO list) with features like:
- Create, read, update, and delete tasks
- Mark tasks as completed
- Filter tasks by status
- Data persistence in SQLite database

## 🛠️ Tech Stack

- **Ruby**: 3.3.x
- **Rails**: 7.1.x
- **Database**: SQLite
- **Testing**: RSpec + Rails
- **Editor**: VS Code
- **Environment**: Linux/macOS with zsh or bash

## 🚀 Installation and Environment Setup

### 1. Install rbenv (Ruby Version Manager)

```bash
# Install dependencies
# macOS (using Homebrew):
brew install rbenv ruby-build

# Linux (Ubuntu/Debian):
sudo apt update
sudo apt install -y rbenv ruby-build

# Add rbenv to your shell configuration
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc for bash
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc            # or 'bash' instead of 'zsh'

# Reload your shell
source ~/.zshrc  # or source ~/.bashrc
rbenv --version
```

### 2. Install ruby-build (Plugin for rbenv) if it is not installed

```bash
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

### 3. Install Ruby 3.3.x

```bash
# List available versions
rbenv versions --bare | grep 3.3

# Install Ruby 3.3.2 (or the latest 3.3.x available)
rbenv install 3.3.2

# Set as global version
rbenv global 3.3.2

# Verify
ruby --version
```

### 4. Install Bundler and Rails

```bash
# Update gems
gem update --system

# Install bundler
gem install bundler

# Install Rails 7.1.x
gem install rails -v '~> 7.1.0'

# Verify installation
rails --version
ruby --version
```

### 5. Clone or Create the Repository

```bash
# If cloning an existing repo
git clone <repo-url> todo-rails
cd todo-rails

# Or create a new Rails project
rails new todo-rails --database=sqlite3 --skip-bundle
cd todo-rails
```

### 6. Install Project Dependencies

```bash
bundle install
```

### 7. Install and Setup RSpec

```bash
bundle add rspec-rails --group development, test
rails generate rspec:install
```

This generates the RSpec configuration files.

**We'll create the database later when we actually need to test against it.**

## 🔧 VS Code Configuration

### Recommended Extensions

Install these extensions in VS Code for the best Ruby/Rails development experience:

1. **Ruby LSP** (`Shopify.ruby-lsp`)
   - Official Language Server Protocol for Ruby
   - Provides IntelliSense, diagnostics, and formatting

2. **Ruby Sorbet** (`Shopify.ruby-sorbet`)
   - Type checking for Ruby (optional, but pairs well with Ruby LSP)

3. **Rails** (`betterlandmark.rails`)
   - Rails-specific shortcuts and navigation

4. **RSpec** (`karunamurti.rspec`)
   - RSpec snippets and syntax highlighting

5. **Better RSpec** (`solutionrovers.better-rspec`)
   - Enhanced RSpec integration with test runners

6. **Test Explorer UI** (`hbenl.test-explorer-ui`)
   - Visual interface for running and managing tests

7. **GitLens** (`eamodio.gitlens`)
   - Enhanced Git integration and blame information

8. **Prettier - Code formatter** (`esbenp.prettier-vscode`)
   - Code formatter (optional but recommended)

### VS Code Settings Configuration

Open the command palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and search for "Preferences: Open Settings (JSON)". Add or modify these settings:

```json
{
  "[ruby]": {
    "editor.defaultFormatter": "Shopify.ruby-lsp",
    "editor.formatOnSave": true,
    "editor.insertSpaces": true,
    "editor.tabSize": 2,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit"
    }
  },
  "rubyLsp.enableBundlerMetadataCache": true,
  "rubyLsp.formatter": "standard",
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  }
}
```

### Install Standard (Ruby Formatter/Linter)

```bash
bundle add standard --group development
```

Standard is a zero-config Ruby style guide that works great with Ruby LSP.

## ▶️ Running and Debugging Tests in VS Code

### Keyboard Shortcuts for Tests

Add these custom keybindings for faster test execution. Open the command palette (`Ctrl+Shift+P` / `Cmd+Shift+P`), search for "Preferences: Open Keyboard Shortcuts (JSON)" and add:

```json
[
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.terminal.sendSequence",
    "args": {
      "text": "bundle exec rspec\u000D"
    },
    "when": "terminalFocus"
  },
  {
    "key": "ctrl+shift+t",
    "command": "workbench.action.terminal.focus"
  },
  {
    "key": "ctrl+shift+r",
    "command": "workbench.action.terminal.sendSequence",
    "args": {
      "text": "bundle exec rspec ${relativeFile}\u000D"
    },
    "when": "editorTextFocus && resourceLangId == ruby"
  },
  {
    "key": "ctrl+shift+d",
    "command": "workbench.action.terminal.sendSequence",
    "args": {
      "text": "bundle exec rspec ${relativeFile} --format documentation\u000D"
    },
    "when": "editorTextFocus && resourceLangId == ruby"
  }
]
```

**Keyboard shortcuts defined:**
- `Ctrl+Shift+T`: Run all tests
- `Ctrl+Shift+R`: Run current spec file
- `Ctrl+Shift+D`: Run current spec file with detailed output

### Option 1: Use Test Explorer UI (Recommended)

1. Install the **Test Explorer UI** and **Better RSpec** extensions
2. Tests will appear in a visual panel on the sidebar
3. Click the play icon to run individual tests or entire suites
4. Results display in real-time

### Option 2: Use Integrated Terminal

Run tests directly from the integrated terminal (`Ctrl+`` / `Cmd+`` on macOS):

```bash
# Run all tests
bundle exec rspec

# Run specific spec file
bundle exec rspec spec/models/todo_spec.rb

# Run with detailed output
bundle exec rspec --format documentation

# Run with color output
bundle exec rspec --format documentation --color
```

### Option 3: Debugging Tests

Install the Ruby debugger:

```bash
bundle add debug --group development
```

Add `debugger` in your spec file where you want to pause:

```ruby
it 'creates a todo' do
  debugger
  # Your test code here
end
```

Run the spec:

```bash
bundle exec rspec spec/your_spec.rb --format documentation
```

The execution will pause at the `debugger` line where you can inspect variables and step through code.

## 📁 Project Structure

```
todo-rails/
├── app/
│   ├── models/
│   ├── controllers/
│   ├── views/
│   └── ...
├── spec/
│   ├── models/
│   ├── controllers/
│   ├── features/
│   └── spec_helper.rb
├── db/
│   ├── migrate/
│   └── seeds.rb
├── config/
├── Gemfile
├── Gemfile.lock
├── README.md
└── .rspec
```

## 🔄 TDD Workflow

We'll follow this cycle for each lesson:

1. **Red**: Write a test that fails
2. **Green**: Write minimal code to pass the test
3. **Refactor**: Improve the code without breaking tests

```bash
# Typical cycle
bundle exec rspec                    # See tests failing
# → Write code
bundle exec rspec                    # See tests passing
# → Refactor if needed
bundle exec rspec                    # Verify tests still pass
```

## 📚 About the Database

**Why don't we create the database yet?**

We'll start with unit tests for models that don't require a database. Once we need to test persistence or database interactions, we'll run:

```bash
rails db:create
rails db:migrate
```

This keeps our setup minimal and lets us focus on learning TDD without unnecessary overhead.

## 📚 Lessons

- Lesson 1: Environment Setup
- Lesson 2: Generate Todo Model
- Lesson 3: Tests for Creating Tasks
- Lesson 4: List Tasks
- Lesson 5: Update Tasks
- Lesson 6: Mark Tasks as Complete
- Lesson 7: Delete Tasks
- Lesson 8: Views and Controllers
- ... (more lessons)

## 🎓 Useful Resources

- [Rails Guides](https://guides.rubyonrails.org)
- [RSpec Documentation](https://rspec.info)
- [Ruby on Rails API](https://api.rubyonrails.org)
- [Better Specs](https://www.betterspecs.org) - RSpec best practices
- [Ruby LSP](https://shopify.github.io/ruby-lsp/) - Official Ruby Language Server

## ✅ Setup Checklist

- [ ] Ruby 3.3.x installed and set as local version
- [ ] Rails 7.1.x installed globally
- [ ] Repository cloned or created
- [ ] `bundle install` completed
- [ ] RSpec configured with `rails generate rspec:install`
- [ ] Ruby LSP extension installed
- [ ] Standard formatter installed and configured
- [ ] Keyboard shortcuts added for test execution
- [ ] Integrated terminal working
- [ ] First test file created and executable

## 🚦 Quick Start Verification

Once you've completed the setup, verify everything works:

```bash
rails --version
ruby --version
bundle exec rspec --version
git status
```

All set! We're ready to start Lesson 2: Generate the Todo Model.

---

**Created**: November 2025
**Goal**: Learn Ruby on Rails with TDD
**Level**: Beginner