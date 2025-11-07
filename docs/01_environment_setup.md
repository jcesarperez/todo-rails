# Lesson 1: Environment Setup

**Objective**: Set up a complete Ruby on Rails development environment with all tools configured for TDD.

## Rails Project Structure

When you create a new Rails project, it generates this directory structure:

```
todo-rails/
├── app/                  # Your application code (models, controllers, views)
├── bin/                  # Executable scripts (rails command, etc.)
├── config/               # Configuration files (database, routes, etc.)
├── db/                   # Database migrations and schema
├── lib/                  # Custom library code
├── public/               # Static files and assets
├── spec/                 # RSpec test files (TDD - what we use)
├── test/                 # Default Rails tests (we skip this and use spec/)
├── vendor/               # Third-party gems and libraries
├── config.ru             # Rack server configuration
├── Dockerfile            # Docker configuration
├── Gemfile               # Ruby gems dependencies
├── Gemfile.lock          # Locked gem versions (don't edit manually)
├── Rakefile              # Rails automation tasks
└── .gitignore
```

**Note**: We focus on the `spec/` directory for our TDD approach, not the default `test/` directory.

## Prerequisites Checklist

Before starting, ensure you have:
- [ ] Ruby version manager installed (`rbenv` or `asdf`)
- [ ] `git` installed and configured
- [ ] VS Code installed
- [ ] Access to a terminal (zsh or bash)

## Step 1: Install Ruby 3.3.x

```bash
# macOS (using Homebrew):
brew install rbenv ruby-build

# Linux (Ubuntu/Debian):
sudo apt update
sudo apt install -y rbenv ruby-build

# Add rbenv to your shell configuration
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc  # or ~/.bashrc
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc            # or 'bash' instead of 'zsh'

# Reload your shell
source ~/.zshrc  # or source ~/.bashrc

# Verify rbenv is working
rbenv --version
```

```bash
# Install Ruby 3.3.x
rbenv install 3.3.2

# Set as global default
rbenv global 3.3.2

# Verify
ruby --version  # Should output: ruby 3.3.2 (...)
```

## Step 2: Install Rails and Bundler

```bash
# Update RubyGems
gem update --system

# Install Bundler
gem install bundler

# Install Rails 7.1.x
gem install rails -v '~> 7.1.0'

# Verify
rails --version   # Should output: Rails 7.1.x
ruby --version    # Should output: ruby 3.3.2
```

## Step 3: Create a New Rails Project

```bash
# Create new project with SQLite database
rails new todo-rails --database=sqlite3 --skip-bundle

# Navigate into the project
cd todo-rails
```

## Step 4: Install Project Dependencies

```bash
# Install gems from Gemfile
bundle install

# This installs all required gems locally in the project
```

## Step 5: Install and Configure RSpec

```bash
# Add RSpec Rails gem to development and test groups
bundle add rspec-rails --group development, test

# Add Shoulda Matchers for advanced assertions
bundle add shoulda-matchers --group development, test

# Generate RSpec configuration
rails generate rspec:install

# This creates:
# - spec/spec_helper.rb
# - spec/rails_helper.rb
# - .rspec configuration file
```

## Step 5b: Configure Shoulda Matchers

Open `spec/rails_helper.rb` and add this at the **end of the file** (after the `RSpec.configure` block):

```ruby
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

This enables matchers like `validate_presence_of` that we'll use in tests.

## Step 6: Install Code Quality Tools

```bash
# Install Standard (Ruby formatter and linter)
bundle add standard --group development

# Verify it's installed
bundle exec standard --version
```

## Step 7: Configure VS Code

### VS Code Settings Configuration

The project includes pre-configured settings. If you need to adjust them, open `.vscode/settings.json` and use:

```json
{
  "[ruby]": {
    "editor.defaultFormatter": "Shopify.ruby-lsp",
    "editor.formatOnSave": true,
    "editor.insertSpaces": true,
    "editor.tabSize": 2
  },
  "rubyLsp.enableBundlerMetadataCache": true,
  "rubyLsp.formatter": "standard",
  "rubyLsp.testExplorer": false,
  "rubyLsp.enableTestLogs": false
}
```

**Key settings:**
- `rubyLsp.testExplorer: false` - Disables Ruby LSP's test explorer (we use Better RSpec)
- `rubyLsp.enableTestLogs: false` - Prevents test error logs from Ruby LSP

## Step 8: Initialize Git Repository

```bash
# Initialize Git
git init

# Add all project files
git add .

# Create initial commit
git commit -m "Initial Rails setup with RSpec"

# (Optional) Add remote repository
git remote add origin <your-repo-url>
git push -u origin main
```

## Step 9: Verify Everything Works

Run these commands to ensure your setup is complete:

```bash
# Check versions
ruby --version
rails --version
bundle --version

# Check RSpec works
bundle exec rspec --version

# Check formatter works
bundle exec standard --version

# Create a simple test file to verify
mkdir -p spec/models
```

Create `spec/models/smoke_test_spec.rb`:

```ruby
RSpec.describe "Smoke Test" do
  it "works" do
    expect(true).to be(true)
  end
end
```

Run the test:

```bash
# Run the smoke test from terminal
bundle exec rspec spec/models/smoke_test_spec.rb

# Or use Better RSpec in VS Code:
# 1. Open the spec file in the editor
# 2. Look for "Better RSpec" panel in the left sidebar
# 3. Click the play icon next to "Smoke Test"
```

Expected output:

```
Smoke Test
  works

Finished in 0.1234 seconds (files took 0.5678 seconds to load)
1 example, 0 failures
```

If you see "1 example, 0 failures" - congratulations! ✅

**Note**: You might see error messages from Ruby LSP in the Test Results panel. This is normal and can be ignored. We use Better RSpec for testing, not Ruby LSP.

### Step 10: Cleanup

Delete the smoke test file:

```bash
rm spec/models/smoke_test_spec.rb
```

## 🎯 Completion Checklist

- [ ] Ruby 3.3.x installed and verified
- [ ] Rails 7.1.x installed and verified
- [ ] Rails project created: `todo-rails`
- [ ] Bundle install completed
- [ ] RSpec installed and configured
- [ ] Standard formatter installed
- [ ] VS Code extensions installed
- [ ] Git repository initialized
- [ ] Smoke test passed
- [ ] Ready to start Lesson 2

## 📝 What You've Learned

- How to set up a Ruby on Rails development environment
- How to initialize a Rails project with SQLite
- How to install and configure RSpec for TDD
- How to configure VS Code for Rails development
- How to run your first test

## 🚀 Next Lesson

Proceed to **[Lesson 2: Generate Todo Model](./02_generate_todo_model.md)** to start building the TODO list application.

---

**Lesson Status**: ✅ Complete
**Time Estimate**: 30-45 minutes
**Difficulty**: Beginner