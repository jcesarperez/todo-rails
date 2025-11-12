# Lesson 8: Views and Controllers

**Objective**: Create HTTP endpoints and views to interact with todos through a web interface.

**What we'll build**: A RESTful controller, routes, and HTML views for listing, creating, updating, and deleting todos.

## Understanding Rails MVC Architecture

Rails follows the Model-View-Controller pattern:

- **Model** (already built!) - Business logic, validations, database
- **Controller** - Handles HTTP requests, coordinates with models
- **View** - HTML templates that display data to users
- **Route** - Maps URLs to controller actions

## Understanding RESTful Routing

REST (Representational State Transfer) is a convention for HTTP endpoints:

| HTTP Method | URL | Action | Purpose |
|-------------|-----|--------|---------|
| GET | `/todos` | index | List all todos |
| GET | `/todos/new` | new | Show form to create |
| POST | `/todos` | create | Save new todo |
| GET | `/todos/:id` | show | Show single todo |
| GET | `/todos/:id/edit` | edit | Show edit form |
| PATCH/PUT | `/todos/:id` | update | Save changes |
| DELETE | `/todos/:id` | destroy | Delete todo |

Rails generates all this automatically with `resources :todos`.

---

## Step 1: Generate the Controller with Tests

```bash
rails generate controller Todos index show new edit --skip-test
```

This creates:
- `app/controllers/todos_controller.rb`
- Views directory structure
- Routes (we'll update these)

**Why `--skip-test`?** We'll write request specs in `spec/requests/` instead of Rails' default tests.

---

## Step 2: Configure Turbo Rails (REQUIRED for Rails 7.1)

For delete buttons with confirmation to work in Rails 7.1, you MUST configure Turbo first.

### Step 2a: Create `app/javascript/application.js`

Create the file with:

```javascript
import "@hotwired/turbo-rails"
```

### Step 2b: Create `config/importmap.rb`

Create the file with:

```ruby
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js"
```

### Step 2c: Create JavaScript controllers directory

```bash
mkdir -p app/javascript/controllers
```

### Step 2d: Verify `app/views/layouts/application.html.erb` has Turbo loaded

Make sure your layout file has this in the `<head>` section:

```erb
<%= javascript_importmap_tags %>
```

### Step 2e: Bundle and restart

```bash
bundle install
rails server  # Restart the server
```

**This is critical:** Without these files, Turbo won't work and delete confirmations won't function.

---

## Step 3: Set Up Routes

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :todos
  root "todos#index"
end
```

This creates all 7 RESTful routes and sets the homepage to `/todos`.

---

## Step 4: Write Request Specs (Red Phase)

Create the request specs directory and file:

```bash
mkdir -p spec/requests
touch spec/requests/todos_spec.rb
```

Edit `spec/requests/todos_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "Todos", type: :request do
  describe "GET /todos (index)" do
    it "returns successful response" do
      get todos_path
      expect(response).to have_http_status(:ok)
    end

    it "renders index template" do
      get todos_path
      expect(response).to render_template(:index)
    end

    it "assigns all todos to @todos" do
      todo1 = Todo.create!(title: "Task 1")
      todo2 = Todo.create!(title: "Task 2")

      get todos_path

      expect(assigns(:todos)).to eq([todo1, todo2])
    end

    it "displays todos on page" do
      todo = Todo.create!(title: "Buy groceries")
      get todos_path
      expect(response.body).to include("Buy groceries")
    end

    it "shows completed status" do
      todo = Todo.create!(title: "Done task", completed: true)
      get todos_path
      expect(response.body).to include("Done task")
    end
  end

  describe "GET /todos/new (new)" do
    it "returns successful response" do
      get new_todo_path
      expect(response).to have_http_status(:ok)
    end

    it "renders new template" do
      get new_todo_path
      expect(response).to render_template(:new)
    end

    it "assigns a new todo to @todo" do
      get new_todo_path
      expect(assigns(:todo)).to be_a_new(Todo)
    end
  end

  describe "POST /todos (create)" do
    it "creates a new todo with valid params" do
      expect {
        post todos_path, params: { todo: { title: "New task" } }
      }.to change(Todo, :count).by(1)
    end

    it "redirects to show page on success" do
      post todos_path, params: { todo: { title: "New task" } }
      expect(response).to redirect_to(todo_path(Todo.last))
    end

    it "sets flash success message" do
      post todos_path, params: { todo: { title: "New task" } }
      expect(flash[:notice]).to eq("Todo was successfully created.")
    end

    it "does not create todo with invalid params" do
      expect {
        post todos_path, params: { todo: { title: "" } }
      }.not_to change(Todo, :count)
    end

    it "re-renders new template on validation failure" do
      post todos_path, params: { todo: { title: "" } }
      expect(response).to render_template(:new)
    end

    it "displays error messages on failure" do
      post todos_path, params: { todo: { title: "" } }
      expect(response.body).to include("Title can't be blank")
    end
  end

  describe "GET /todos/:id (show)" do
    let(:todo) { Todo.create!(title: "Sample task") }

    it "returns successful response" do
      get todo_path(todo)
      expect(response).to have_http_status(:ok)
    end

    it "renders show template" do
      get todo_path(todo)
      expect(response).to render_template(:show)
    end

    it "assigns the todo to @todo" do
      get todo_path(todo)
      expect(assigns(:todo)).to eq(todo)
    end

    it "displays the todo title" do
      get todo_path(todo)
      expect(response.body).to include(todo.title)
    end

    it "returns 404 for non-existent todo" do
      get todo_path(999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /todos/:id/edit (edit)" do
    let(:todo) { Todo.create!(title: "Sample task") }

    it "returns successful response" do
      get edit_todo_path(todo)
      expect(response).to have_http_status(:ok)
    end

    it "renders edit template" do
      get edit_todo_path(todo)
      expect(response).to render_template(:edit)
    end

    it "assigns the todo to @todo" do
      get edit_todo_path(todo)
      expect(assigns(:todo)).to eq(todo)
    end

    it "pre-fills form with current title" do
      get edit_todo_path(todo)
      expect(response.body).to include(todo.title)
    end
  end

  describe "PATCH /todos/:id (update)" do
    let(:todo) { Todo.create!(title: "Original title") }

    it "updates the todo with valid params" do
      patch todo_path(todo), params: { todo: { title: "Updated title" } }
      expect(todo.reload.title).to eq("Updated title")
    end

    it "redirects to show page on success" do
      patch todo_path(todo), params: { todo: { title: "Updated title" } }
      expect(response).to redirect_to(todo_path(todo))
    end

    it "sets flash success message" do
      patch todo_path(todo), params: { todo: { title: "Updated title" } }
      expect(flash[:notice]).to eq("Todo was successfully updated.")
    end

    it "updates completed status" do
      patch todo_path(todo), params: { todo: { completed: true } }
      expect(todo.reload.completed).to be(true)
    end

    it "does not update with invalid params" do
      patch todo_path(todo), params: { todo: { title: "" } }
      expect(todo.reload.title).to eq("Original title")
    end

    it "re-renders edit template on failure" do
      patch todo_path(todo), params: { todo: { title: "" } }
      expect(response).to render_template(:edit)
    end

    it "displays error messages on failure" do
      patch todo_path(todo), params: { todo: { title: "" } }
      expect(response.body).to include("Title can't be blank")
    end

    it "returns 404 for non-existent todo" do
      patch todo_path(999), params: { todo: { title: "Updated" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /todos/:id (destroy)" do
    let!(:todo) { Todo.create!(title: "Delete me") }

    it "deletes the todo" do
      expect {
        delete todo_path(todo)
      }.to change(Todo, :count).by(-1)
    end

    it "redirects to index page" do
      delete todo_path(todo)
      expect(response).to redirect_to(todos_path)
    end

    it "sets flash success message" do
      delete todo_path(todo)
      expect(flash[:notice]).to eq("Todo was successfully destroyed.")
    end

    it "returns 404 for non-existent todo" do
      delete todo_path(999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "root path" do
    it "redirects to todos index" do
      get root_path
      expect(response).to redirect_to(todos_path)
    end
  end
end
```

Run the tests to see them fail:

```bash
bundle exec rspec spec/requests/todos_spec.rb
```

You should see many failures - this is expected! ✓ This is the **Red** phase.

---

## Step 5: Implement the Controller (Green Phase)

Edit `app/controllers/todos_controller.rb`:

```ruby
class TodosController < ApplicationController
  before_action :set_todo, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @todos = Todo.all
  end

  def new
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      redirect_to @todo, notice: "Todo was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @todo.update(todo_params)
      redirect_to @todo, notice: "Todo was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo.destroy
    redirect_to todos_url, notice: "Todo was successfully destroyed."
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title, :completed)
  end

  def not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
```

**What we implemented:**

- **`before_action :set_todo`** - Loads todo for show, edit, update, destroy
- **`index`** - Lists all todos
- **`new`** - Shows form to create
- **`create`** - Saves new todo
- **`show`** - Displays single todo
- **`edit`** - Shows edit form
- **`update`** - Saves changes
- **`destroy`** - Deletes todo
- **`todo_params`** - Whitelist allowed parameters (security)
- **`set_todo`** - Helper to find todo by ID
- **`not_found`** - Custom 404 handling

Run the tests:

```bash
bundle exec rspec spec/requests/todos_spec.rb
```

Most should pass now! ✓ This is the **Green** phase.

---

## Step 6: Create the Views

### Create `app/views/todos/index.html.erb`:

```erb
<div class="container">
  <h1>Todos</h1>

  <div class="todos-list">
    <% if @todos.any? %>
      <table class="table">
        <thead>
          <tr>
            <th>Title</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <% @todos.each do |todo| %>
            <tr>
              <td><%= link_to todo.title, todo_path(todo) %></td>
              <td>
                <% if todo.completed? %>
                  <span class="badge completed">✓ Completed</span>
                <% else %>
                  <span class="badge incomplete">○ Incomplete</span>
                <% end %>
              </td>
              <td>
                <%= link_to "Edit", edit_todo_path(todo), class: "btn btn-sm btn-primary" %>
                <%= button_to "Delete", todo_path(todo), 
                    method: :delete, 
                    form: { data: { turbo_confirm: "Are you sure?" } },
                    class: "btn btn-sm btn-danger" %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <p>No todos yet. <%= link_to "Create one!", new_todo_path %></p>
    <% end %>
  </div>

  <%= link_to "New Todo", new_todo_path, class: "btn btn-primary" %>
</div>
```

### Create `app/views/todos/new.html.erb`:

```erb
<div class="container">
  <h1>New Todo</h1>

  <%= form_with(model: @todo, local: true) do |form| %>
    <% if @todo.errors.any? %>
      <div id="error_explanation" class="alert alert-danger">
        <h4><%= pluralize(@todo.errors.count, "error") %> prohibited this todo from being saved:</h4>
        <ul>
          <% @todo.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div class="form-group">
      <%= form.label :title %>
      <%= form.text_field :title, class: "form-control" %>
    </div>

    <div class="form-group">
      <%= form.submit "Create Todo", class: "btn btn-primary" %>
      <%= link_to "Cancel", todos_path, class: "btn btn-secondary" %>
    </div>
  <% end %>
</div>
```

### Create `app/views/todos/edit.html.erb`:

```erb
<div class="container">
  <h1>Edit Todo</h1>

  <%= form_with(model: @todo, local: true) do |form| %>
    <% if @todo.errors.any? %>
      <div id="error_explanation" class="alert alert-danger">
        <h4><%= pluralize(@todo.errors.count, "error") %> prohibited this todo from being saved:</h4>
        <ul>
          <% @todo.errors.full_messages.each do |message| %>
            <li><%= message %></li>
          <% end %>
        </ul>
      </div>
    <% end %>

    <div class="form-group">
      <%= form.label :title %>
      <%= form.text_field :title, class: "form-control" %>
    </div>

    <div class="form-group">
      <%= form.label :completed %>
      <%= form.check_box :completed %>
    </div>

    <div class="form-group">
      <%= form.submit "Update Todo", class: "btn btn-primary" %>
      <%= link_to "Cancel", @todo, class: "btn btn-secondary" %>
    </div>
  <% end %>
</div>
```

### Create `app/views/todos/show.html.erb`:

```erb
<div class="container">
  <h1><%= @todo.title %></h1>

  <div class="todo-details">
    <p>
      <strong>Status:</strong>
      <% if @todo.completed? %>
        <span class="badge completed">✓ Completed</span>
      <% else %>
        <span class="badge incomplete">○ Incomplete</span>
      <% end %>
    </p>

    <p>
      <strong>Created:</strong>
      <%= @todo.created_at.strftime("%B %d, %Y at %I:%M %p") %>
    </p>

    <p>
      <strong>Last updated:</strong>
      <%= @todo.updated_at.strftime("%B %d, %Y at %I:%M %p") %>
    </p>
  </div>

  <div class="actions">
    <%= link_to "Edit", edit_todo_path(@todo), class: "btn btn-primary" %>
    <%= button_to "Delete", todo_path(@todo), 
        method: :delete, 
        form: { data: { turbo_confirm: "Are you sure?" } },
        class: "btn btn-danger" %>
    <%= link_to "Back to Todos", todos_path, class: "btn btn-secondary" %>
  </div>
</div>
```

---

## Step 7: Create a Layout

Update `app/views/layouts/application.html.erb`:

```erb
<!DOCTYPE html>
<html>
  <head>
    <title>Todo Rails</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    <style>
      body { font-family: Arial, sans-serif; margin: 0; padding: 0; }
      .container { max-width: 900px; margin: 0 auto; padding: 20px; }
      h1 { color: #333; }
      .table { width: 100%; border-collapse: collapse; margin: 20px 0; }
      .table th, .table td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
      .table th { background-color: #f5f5f5; }
      .btn { display: inline-block; padding: 8px 12px; margin: 5px; text-decoration: none; border-radius: 4px; cursor: pointer; border: none; }
      .btn-primary { background-color: #007bff; color: white; }
      .btn-secondary { background-color: #6c757d; color: white; }
      .btn-danger { background-color: #dc3545; color: white; }
      .btn:hover { opacity: 0.8; }
      .btn-sm { padding: 4px 8px; font-size: 12px; }
      .badge { padding: 4px 8px; border-radius: 3px; font-size: 12px; }
      .badge.completed { background-color: #28a745; color: white; }
      .badge.incomplete { background-color: #ffc107; color: black; }
      .form-group { margin: 15px 0; }
      .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
      .form-control { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
      .alert { padding: 15px; margin: 15px 0; border-radius: 4px; }
      .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
      .flash { margin: 15px 0; padding: 15px; background-color: #d4edda; color: #155724; border-radius: 4px; }
      .actions { margin: 20px 0; }
      .todo-details { margin: 20px 0; padding: 15px; background-color: #f9f9f9; border-radius: 4px; }
      .todos-list { margin: 20px 0; }
      button { cursor: pointer; }
      form { display: inline; }
    </style>
  </head>
  <body>
    <% if notice %>
      <div class="flash"><%= notice %></div>
    <% end %>
    <%= yield %>
  </body>
</html>
```

---

## Step 8: Configure Delete Buttons with Turbo Confirmation

Now that Turbo is properly configured in Step 2, delete buttons work with confirmation:

```erb
<%= button_to "Delete", todo_path(todo), 
    method: :delete, 
    form: { data: { turbo_confirm: "Are you sure?" } },
    class: "btn btn-danger" %>
```

**How it works:**

1. `button_to` creates an invisible HTML form with `method="post"` and hidden `_method=delete`
2. The `form: { data: { turbo_confirm: "..." } }` adds `data-turbo-confirm` to the form
3. When you click Delete, Turbo intercepts the form submission
4. Shows the browser confirmation dialog
5. If confirmed, submits the DELETE request
6. Controller destroys the record and redirects
7. Page updates automatically with Turbo Drive

**Why this syntax?**

- `button_to` generates a `<form>` element
- We need `data-turbo-confirm` on the form, not the button
- That's why we pass it via `form: { data: { turbo_confirm: ... } }`

---

## Step 9: Run All Tests

```bash
bundle exec rspec spec/requests/todos_spec.rb
```

All tests should pass! ✓

Then run all tests:

```bash
bundle exec rspec
```

Expected: All tests passing (107 model tests + request tests)

---

## Step 10: Test Manually

Start the Rails server:

```bash
rails server
```

Visit `http://localhost:3000` in your browser and:
- ✅ See the todos list
- ✅ Create a new todo
- ✅ Edit a todo
- ✅ Mark as complete
- ✅ Delete a todo (with confirmation dialog!) ✅

---

## Understanding Rails 7.1 Turbo Configuration

**What is Turbo?**

Turbo Drive is Rails 7's replacement for Turbolinks. It intercepts link clicks and form submissions to enable faster page navigation without full page reloads.

**Why do we need it for DELETE?**

- HTTP only supports GET and POST natively in browsers
- DELETE requests require JavaScript to work from a link or button
- Turbo Drive handles converting `method: :delete` form submissions properly
- It also handles `data-turbo-confirm` confirmations

**Configuration summary:**

| File | Purpose | Content |
|------|---------|---------|
| `app/javascript/application.js` | Main JS entry point | `import "@hotwired/turbo-rails"` |
| `config/importmap.rb` | Module mapping | Maps `@hotwired/turbo-rails` to CDN URL |
| `app/views/layouts/application.html.erb` | Load JavaScript | `<%= javascript_importmap_tags %>` |

**Common issues and solutions:**

| Problem | Solution |
|---------|----------|
| Delete doesn't show confirmation | Turbo not loaded - check `importmap.rb` and `application.js` |
| "Failed to resolve module specifier" error | Wrong module name - use only `@hotwired/turbo-rails`, not `stimulus-autoload` |
| Delete works but doesn't redirect | Check that controller's `destroy` action calls `redirect_to` |

**Rails 7.1 Pattern for Delete Buttons:**

```erb
<!-- Always use button_to for destructive actions -->
<%= button_to "Delete", resource_path(resource), 
    method: :delete, 
    form: { data: { turbo_confirm: "Are you sure?" } },
    class: "btn btn-danger" %>
```

This is the standard Rails 7.1+ way to handle deletions.

---

## Understanding Turbo Drive Behavior

**Prefetching Links**

You may notice Turbo making background GET requests to pages with links (like `/todos/new`). This is **Turbo Prefetch**, a normal feature that improves performance:

```
Timeline:
1. Page loads with link to /todos/new
2. Turbo detects the link
3. Makes a background GET request to prefetch /todos/new
4. Caches the response
5. When you click the link, page loads instantly from cache
```

**Is this a problem?** No, it's a feature:
- ✅ Makes the app feel faster
- ✅ Only does GET requests (safe, no data changes)
- ✅ Dramatically improves user experience
- ✅ Works great for read-only pages

**Can I disable it?** Yes, if needed:

```erb
<!-- Disable prefetch for specific link -->
<%= link_to "Link", path, data: { turbo_prefetch: false } %>
```

But don't disable it unless you have performance issues. For most Rails applications, prefetching is beneficial and expected behavior.

**Turbo Drive lifecycle:**

- `turbo:load` - Page loaded
- `turbo:before-cache` - Page about to be cached
- `turbo:before-visit` - About to navigate
- `turbo:visit` - Navigating

These are useful for custom JavaScript if you need to react to page navigation. But for basic CRUD operations, you don't need to worry about them.

---

## 🎯 Completion Checklist

- [ ] Generated controller with `rails generate`
- [ ] Configured Turbo Rails (Step 2)
- [ ] Set up routes in `config/routes.rb`
- [ ] Created all request specs in `spec/requests/todos_spec.rb`
- [ ] Implemented TodosController with all 7 actions
- [ ] Created all 4 views (index, new, edit, show)
- [ ] Updated application layout
- [ ] All request tests passing
- [ ] Tested manually in browser
- [ ] Verified error handling works
- [ ] Verified flash messages work
- [ ] Delete with confirmation working

## 📝 What You've Learned

- RESTful routing and the 7 standard actions
- Request specs and testing HTTP behavior
- Rails controller patterns and conventions
- Strong parameters for security
- Before actions for DRY code
- Error handling and 404 responses
- Flash messages across redirects
- ERB templating syntax
- Form helpers with `form_with`
- Link helpers and URL generation
- Status codes and HTTP responses
- Turbo Drive configuration and usage
- Delete buttons with confirmation
- Turbo prefetching behavior

## 🔍 Key Controller Patterns Reference

| Pattern | Purpose |
|---------|---------|
| `before_action` | Run code before action |
| `set_todo` | Load resource by ID |
| `params.require().permit()` | Strong parameters (security) |
| `redirect_to` | HTTP redirect with status |
| `render` | Render template or HTML |
| `rescue_from` | Catch exceptions |
| `flash[:notice]` | Message persistent across redirect |

## 🚀 Next Steps

- Add Bootstrap CSS for better styling
- Add delete confirmation modals
- Implement todo filtering (by status)
- Add search functionality
- Deploy to production

---

**Lesson Status**: ✅ Complete
**Time Estimate**: 30-40 minutes
**Difficulty**: Intermediate