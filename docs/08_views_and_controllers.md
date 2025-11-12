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

## Step 1: Generate the Controller with Tests

```bash
rails generate controller Todos index show new edit --skip-test
```

This creates:
- `app/controllers/todos_controller.rb`
- Views directory structure
- Routes (we'll update these)

**Why `--skip-test`?** We'll write request specs in `spec/requests/` instead of Rails' default tests.

## Step 4: Set Up Routes

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :todos
  root "todos#index"
end
```

This creates all 7 RESTful routes and sets the homepage to `/todos`.

## Step 5: Write Request Specs (Red Phase)

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

## Step 4: Implement the Controller (Green Phase)

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
    redirect_to todos_url, notice: "Todo was successfully destroyed.", status: :see_other
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

## Step 8: Configure Delete Buttons with Turbo Confirmation

Now that Turbo is configured, use `button_to` with `turbo_confirm`:

### In `app/views/todos/index.html.erb`:

```erb
<%= button_to "Delete", todo_path(todo), 
    method: :delete, 
    form: { data: { turbo_confirm: "Are you sure?" } },
    class: "btn btn-sm btn-danger" %>
```

### In `app/views/todos/show.html.erb`:

```erb
<%= button_to "Delete", todo_path(@todo), 
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

**Important: Why `form: { data: { turbo_confirm: ... } }`?**

- `button_to` generates a `<form>` element
- We need `data-turbo-confirm` on the form, not the button
- That's why we pass it via `form: { data: { ... } }`

## Step 9: Create the Views

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

## Step 6: Create a Layout

Create `app/views/layouts/application.html.erb` (it should already exist, update the body):

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
      .btn { display: inline-block; padding: 8px 12px; margin: 5px; text-decoration: none; border-radius: 4px; }
      .btn-primary { background-color: #007bff; color: white; }
      .btn-secondary { background-color: #6c757d; color: white; }
      .btn-danger { background-color: #dc3545; color: white; }
      .btn:hover { opacity: 0.8; }
      .badge { padding: 4px 8px; border-radius: 3px; font-size: 12px; }
      .badge.completed { background-color: #28a745; color: white; }
      .badge.incomplete { background-color: #ffc107; color: black; }
      .form-group { margin: 15px 0; }
      .form-group label { display: block; margin-bottom: 5px; font-weight: bold; }
      .form-control { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; font-size: 14px; }
      .alert { padding: 15px; margin: 15px 0; border-radius: 4px; }
      .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
      .flash { margin: 15px 0; padding: 15px; background-color: #d4edda; color: #155724; border-radius: 4px; }
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

## Step 7: Run All Tests

```bash
bundle exec rspec spec/requests/todos_spec.rb
```

All tests should pass! ✓

Then run all tests:

```bash
bundle exec rspec
```

Expected: All tests passing (107 model tests + new request tests)

## Step 8: Test Manually

Start the Rails server:

```bash
rails server
```

Visit `http://localhost:3000` in your browser and:
- ✅ See the todos list
- ✅ Create a new todo
- ✅ Edit a todo
- ✅ Mark as complete
- ✅ Delete a todo

## Important: Rails 7 Delete Links with Turbo

**What is Turbo?**

Rails 7 uses Turbo Drive (formerly Turbolinks) for faster page navigation. It intercepts link clicks and form submissions.

**Why `method: :delete` doesn't work**

In Rails 7, old `method: :delete` with UJS (Unobtrusive JavaScript) no longer works. Instead, use:

```erb
<!-- ❌ OLD - Rails 6 and earlier (doesn't work in Rails 7) -->
<%= link_to "Delete", todo_path(@todo), 
    method: :delete, 
    data: { confirm: "Are you sure?" } %>

<!-- ✅ NEW - Rails 7+ with Turbo -->
<%= link_to "Delete", todo_path(@todo), 
    data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %>
```

**The differences:**

| Feature | Old (Rails 6) | New (Rails 7) |
|---------|---------------|---------------|
| HTTP method | `method: :delete` | `data: { turbo_method: :delete }` |
| Confirmation | `data: { confirm: "..." }` | `data: { turbo_confirm: "..." }` |
| Library | UJS (Unobtrusive JS) | Turbo Drive |
| Still supported? | No (deprecated) | Yes ✅ |

**How it works:**

1. User clicks delete link
2. Turbo intercepts the click
3. Shows confirmation dialog (if `turbo_confirm` present)
4. Sends DELETE request to Rails
5. Server destroys the record
6. Redirects back to todos list
7. Turbo updates the page without full reload

**Debugging delete not working:**

```erb
<!-- Check that you have both data attributes -->
data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }

<!-- ❌ Incorrect -->
method: :delete  <!-- This won't work in Rails 7 -->

<!-- ✅ Correct -->
data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }
```

**Debugging delete not working:**

```erb
<!-- Check that you have both data attributes -->
data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }

<!-- ❌ Incorrect -->
method: :delete  <!-- This won't work in Rails 7 -->

<!-- ✅ Correct for Turbo Stream responses -->
data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }

<!-- ✅ Correct for HTML redirects (RECOMMENDED) -->
data: { turbo_method: :delete, turbo_confirm: "Are you sure?" }, format: :html
```

**The key issue:** In Rails 7, `data: { turbo_method: :delete }` generates a Turbo Stream request. If your destroy action has a `format.turbo_stream` block, the browser won't redirect but waits for the turbo_stream response. To force HTML response and proper redirect, specify `format: :html` in the link_to.

**Solution - Use `button_to` instead of `link_to` for delete:**

```erb
<!-- ❌ OLD - link_to with delete doesn't work reliably -->
<%= link_to "Delete", todo_path(todo), 
    method: :delete, 
    data: { confirm: "Are you sure?" } %>

<!-- ✅ NEW - button_to works reliably in Rails 7 -->
<%= button_to "Delete", todo_path(todo), 
    method: :delete, 
    data: { confirm: "Are you sure?" },
    class: "btn btn-danger",
    form: { style: "display: inline;" } %>
```

**Why `button_to` instead of `link_to`?**

- `link_to` with `method: :delete` is a hack - it tries to use JavaScript to convert a GET request to DELETE
- `button_to` creates a real HTML form with hidden fields
- Forms with `method: :delete` are handled natively by Rails
- More reliable and works even if JavaScript has issues
- The `form: { style: "display: inline;" }` makes it look like a button

**Why `button_to` instead of `link_to`?**

- `link_to` with `method: :delete` is a hack - it tries to use JavaScript to convert a GET request to DELETE
- `button_to` creates a real HTML form with hidden fields
- Forms with `method: :delete` are handled natively by Rails
- More reliable and works even if JavaScript has issues
- The `form: { style: "display: inline;" }` makes it look like a button

**Confirmation dialog:**

Use `form: { data: { turbo_confirm: "message" } }` for proper Rails 7 confirmation:

```erb
<!-- ✅ CORRECT for Rails 7.1 with button_to -->
<%= button_to "Delete", todo_path(todo), 
    method: :delete, 
    form: { data: { turbo_confirm: "Are you sure?" } },
    class: "btn btn-danger" %>
```

**Why this syntax?**

- `button_to` generates an HTML `<form>` element internally
- In Rails 7, `data-turbo-confirm` is the attribute Turbo Drive listens for
- We need to pass `data: { turbo_confirm: "..." }` to the **form**, not the button
- That's why we use `form: { data: { turbo_confirm: ... } }`

**How it works step by step:**

1. `button_to` creates an invisible form with `method="post"` and hidden `_method=delete` field
2. The `form: { data: { turbo_confirm: "..." } }` adds `data-turbo-confirm` to the form
3. When you click the button, it submits the form
4. Turbo Drive intercepts the submission and shows the confirmation dialog
5. If you click OK, the form is submitted with DELETE method
6. Rails controller processes the DELETE request
7. `destroy` action deletes the record and redirects
8. Page updates with the deleted todo removed

**With `link_to` (alternative syntax, also works):**

```erb
<!-- ✅ Also works in Rails 7.1 -->
<%= link_to "Delete", todo_path(todo), 
    data: { turbo_method: :delete, turbo_confirm: "Are you sure?" } %>
```

**Key difference:**
- `link_to` with `data-turbo-method` = makes a DELETE request directly
- `button_to` with method :delete = creates a form that submits DELETE
- Both trigger `turbo_confirm` the same way
- `button_to` is more semantically correct (delete is an action that should be a form submission)

**Note on JavaScript errors:**

You may still see `Failed to resolve module specifier "application"` in the console. This is a Turbo/Importmap configuration issue in your Rails setup but doesn't affect basic functionality. The `button_to` with `turbo_confirm` works independently of this error.

## Understanding Controller Patterns

**`before_action :set_todo`**
- Runs before specific actions
- Loads the todo and assigns to `@todo`
- Dry: Don't repeat `@todo = Todo.find(params[:id])`

**`params.require(:todo).permit(:title, :completed)`**
- Security: Only allows these parameters
- Prevents mass assignment vulnerabilities
- Called "Strong Parameters"

**Flash messages**
- `redirect_to @todo, notice: "..."`
- Message persists across redirect
- Shown on next page load

**Error handling**
- `.save` returns false on validation failure
- Render same form with errors
- User sees what went wrong

**`rescue_from`**
- Catches `RecordNotFound` exceptions
- Returns 404 instead of crash
- Professional error handling

## 🎯 Completion Checklist

- [ ] Generated controller with `rails generate`
- [ ] Set up routes in `config/routes.rb`
- [ ] Created all request specs in `spec/requests/todos_spec.rb`
- [ ] Implemented TodosController with all 7 actions
- [ ] Created all 4 views (index, new, edit, show)
- [ ] Updated application layout
- [ ] All request tests passing
- [ ] Tested manually in browser
- [ ] Verified error handling works
- [ ] Verified flash messages work

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
- HTML rendering in Rails

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