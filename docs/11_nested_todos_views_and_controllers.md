# Lesson 11: Nested Todos - Views and Controllers

**Objective**: Create HTTP endpoints and views for managing Todos within TodoLists using nested routes.

**What we'll build**: A nested TodosController that handles creating, viewing, and deleting todos within a specific TodoList. Plus update the root route to point to TodoLists.

---

## Step 0: Update Root Route

Edit `config/routes.rb` and change the root route:

```ruby
Rails.application.routes.draw do
  resources :todos
  
  resources :todo_lists do
    resources :todos, module: :todo_lists
  end
  
  root "todo_lists#index"
end
```

**What changed:** `root "todo_lists#index"` instead of `root "todos#index"`

Now when users visit `http://localhost:3000`, they'll see the TodoLists index instead of the standalone Todos.

---

## Step 1: Write Request Specs for Nested Todos (Red Phase)

Create the request specs:

```bash
touch spec/requests/todo_lists/todos_spec.rb
```

Edit `spec/requests/todo_lists/todos_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "TodoLists::Todos", type: :request do
  let(:todo_list) { TodoList.create!(title: "My List") }

  describe "GET /todo_lists/:todo_list_id/todos (index)" do
    it "returns successful response" do
      get todo_list_todos_path(todo_list)
      expect(response).to have_http_status(:ok)
    end

    it "renders index template" do
      get todo_list_todos_path(todo_list)
      expect(response).to render_template(:index)
    end

    it "assigns todos to @todos" do
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")

      get todo_list_todos_path(todo_list)

      expect(assigns(:todos)).to eq([todo1, todo2])
    end

    it "displays todos on page" do
      todo = todo_list.todos.create!(title: "Buy milk")
      get todo_list_todos_path(todo_list)
      expect(response.body).to include("Buy milk")
    end
  end

  describe "GET /todo_lists/:todo_list_id/todos/new (new)" do
    it "returns successful response" do
      get new_todo_list_todo_path(todo_list)
      expect(response).to have_http_status(:ok)
    end

    it "renders new template" do
      get new_todo_list_todo_path(todo_list)
      expect(response).to render_template(:new)
    end

    it "assigns a new todo to @todo" do
      get new_todo_list_todo_path(todo_list)
      expect(assigns(:todo)).to be_a_new(Todo)
    end

    it "assigns the todo_list to @todo_list" do
      get new_todo_list_todo_path(todo_list)
      expect(assigns(:todo_list)).to eq(todo_list)
    end
  end

  describe "POST /todo_lists/:todo_list_id/todos (create)" do
    it "creates a new todo in the list with valid params" do
      expect {
        post todo_list_todos_path(todo_list), params: { todo: { title: "New task" } }
      }.to change(todo_list.todos, :count).by(1)
    end

    it "associates the todo with the todo_list" do
      post todo_list_todos_path(todo_list), params: { todo: { title: "New task" } }
      expect(Todo.last.todo_list).to eq(todo_list)
    end

    it "redirects to todo_list show page on success" do
      post todo_list_todos_path(todo_list), params: { todo: { title: "New task" } }
      expect(response).to redirect_to(todo_list_path(todo_list))
    end

    it "sets flash success message" do
      post todo_list_todos_path(todo_list), params: { todo: { title: "New task" } }
      expect(flash[:notice]).to eq("Todo was successfully created.")
    end

    it "does not create with invalid params" do
      expect {
        post todo_list_todos_path(todo_list), params: { todo: { title: "" } }
      }.not_to change(todo_list.todos, :count)
    end

    it "re-renders new template on failure" do
      post todo_list_todos_path(todo_list), params: { todo: { title: "" } }
      expect(response).to render_template(:new)
    end

    it "displays error messages on failure" do
      post todo_list_todos_path(todo_list), params: { todo: { title: "" } }
      expect(response.body).to include("prohibited this todo from being saved")
    end
  end

  describe "GET /todo_lists/:todo_list_id/todos/:id (show)" do
    let(:todo) { todo_list.todos.create!(title: "Sample task") }

    it "returns successful response" do
      get todo_list_todo_path(todo_list, todo)
      expect(response).to have_http_status(:ok)
    end

    it "renders show template" do
      get todo_list_todo_path(todo_list, todo)
      expect(response).to render_template(:show)
    end

    it "assigns the todo to @todo" do
      get todo_list_todo_path(todo_list, todo)
      expect(assigns(:todo)).to eq(todo)
    end

    it "assigns the todo_list to @todo_list" do
      get todo_list_todo_path(todo_list, todo)
      expect(assigns(:todo_list)).to eq(todo_list)
    end

    it "displays the todo title" do
      get todo_list_todo_path(todo_list, todo)
      expect(response.body).to include(todo.title)
    end

    it "returns 404 for non-existent todo" do
      get todo_list_todo_path(todo_list, 999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /todo_lists/:todo_list_id/todos/:id (destroy)" do
    let!(:todo) { todo_list.todos.create!(title: "Delete me") }

    it "deletes the todo" do
      expect {
        delete todo_list_todo_path(todo_list, todo)
      }.to change(todo_list.todos, :count).by(-1)
    end

    it "redirects to todo_list show page" do
      delete todo_list_todo_path(todo_list, todo)
      expect(response).to redirect_to(todo_list_path(todo_list))
    end

    it "sets flash success message" do
      delete todo_list_todo_path(todo_list, todo)
      expect(flash[:notice]).to eq("Todo was successfully destroyed.")
    end

    it "returns 404 for non-existent todo" do
      delete todo_list_todo_path(todo_list, 999)
      expect(response).to have_http_status(:not_found)
    end
  end
end
```

Run the tests to see them fail:

```bash
bundle exec rspec spec/requests/todo_lists/todos_spec.rb
```

You should see many failures. ✓ This is the **Red** phase.

---

## Step 2: Generate Nested TodosController (Green Phase)

Create the controller directory and file:

```bash
mkdir -p app/controllers/todo_lists
touch app/controllers/todo_lists/todos_controller.rb
```

Edit `app/controllers/todo_lists/todos_controller.rb`:

```ruby
module TodoLists
  class TodosController < ApplicationController
    before_action :set_todo_list
    before_action :set_todo, only: [:show, :destroy]
    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    def index
      @todos = @todo_list.todos
    end

    def new
      @todo = @todo_list.todos.build
    end

    def create
      @todo = @todo_list.todos.build(todo_params)

      if @todo.save
        redirect_to @todo_list, notice: "Todo was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def destroy
      @todo.destroy
      redirect_to @todo_list, notice: "Todo was successfully destroyed."
    end

    private

    def set_todo_list
      @todo_list = TodoList.find(params[:todo_list_id])
    end

    def set_todo
      @todo = @todo_list.todos.find(params[:id])
    end

    def todo_params
      params.require(:todo).permit(:title, :completed)
    end

    def not_found
      render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end
end
```

**What we implemented:**

- **`before_action :set_todo_list`** - Loads the parent TodoList for all actions
- **`before_action :set_todo`** - Loads the todo for show and destroy
- **`index`** - Lists todos in the list
- **`new`** - Shows form to create todo in list
- **`create`** - Saves new todo to list
- **`show`** - Displays single todo
- **`destroy`** - Deletes todo from list
- **Important:** Uses `@todo_list.todos.build` to ensure the todo belongs to the list
- **Important:** Uses `@todo_list.todos.find` to ensure we only find todos from this list

Run the tests:

```bash
bundle exec rspec spec/requests/todo_lists/todos_spec.rb
```

All should pass! ✓ This is the **Green** phase.

---

## Step 3: Create Nested Todos Views

### Create `app/views/todo_lists/todos/index.html.erb`:

```erb
<div class="container">
  <h1>Todos in <%= @todo_list.title %></h1>

  <div class="todos-in-list">
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
              <td><%= link_to todo.title, todo_list_todo_path(@todo_list, todo) %></td>
              <td>
                <% if todo.completed? %>
                  <span class="badge completed">✓ Completed</span>
                <% else %>
                  <span class="badge incomplete">○ Incomplete</span>
                <% end %>
              </td>
              <td>
                <%= button_to "Delete", todo_list_todo_path(@todo_list, todo), 
                    method: :delete, 
                    form: { data: { turbo_confirm: "Are you sure?" } },
                    class: "btn btn-sm btn-danger" %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <p>No todos in this list yet.</p>
    <% end %>
  </div>

  <%= link_to "New Todo", new_todo_list_todo_path(@todo_list), class: "btn btn-primary" %>
  <%= link_to "Back to List", todo_list_path(@todo_list), class: "btn btn-secondary" %>
</div>
```

### Create `app/views/todo_lists/todos/new.html.erb`:

```erb
<div class="container">
  <h1>New Todo in <%= @todo_list.title %></h1>

  <%= form_with(model: [@todo_list, @todo], local: true) do |form| %>
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
      <%= link_to "Cancel", todo_list_path(@todo_list), class: "btn btn-secondary" %>
    </div>
  <% end %>
</div>
```

### Create `app/views/todo_lists/todos/show.html.erb`:

```erb
<div class="container">
  <h1><%= @todo.title %></h1>

  <div class="todo-details">
    <p>
      <strong>List:</strong>
      <%= link_to @todo_list.title, todo_list_path(@todo_list) %>
    </p>

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
    <%= button_to "Delete", todo_list_todo_path(@todo_list, @todo), 
        method: :delete, 
        form: { data: { turbo_confirm: "Are you sure?" } },
        class: "btn btn-danger" %>
    <%= link_to "Back to List", todo_list_path(@todo_list), class: "btn btn-secondary" %>
  </div>
</div>
```

---

## Step 4: Update TodoList Show View

Update `app/views/todo_lists/show.html.erb` to link to nested todos:

```erb
<div class="container">
  <h1><%= @todo_list.title %></h1>

  <div class="list-stats">
    <p>
      <strong>Total Todos:</strong>
      <%= @todo_list.todos.count %>
    </p>
    <p>
      <strong>Completed:</strong>
      <%= @todo_list.todos.where(completed: true).count %>
    </p>
    <p>
      <strong>Incomplete:</strong>
      <%= @todo_list.todos.where(completed: false).count %>
    </p>
  </div>

  <div class="todos-in-list">
    <h2>Todos</h2>
    <% if @todo_list.todos.any? %>
      <table class="table">
        <thead>
          <tr>
            <th>Title</th>
            <th>Status</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <% @todo_list.todos.each do |todo| %>
            <tr>
              <td><%= link_to todo.title, todo_list_todo_path(@todo_list, todo) %></td>
              <td>
                <% if todo.completed? %>
                  <span class="badge completed">✓ Completed</span>
                <% else %>
                  <span class="badge incomplete">○ Incomplete</span>
                <% end %>
              </td>
              <td>
                <%= link_to "View", todo_list_todo_path(@todo_list, todo), class: "btn btn-sm btn-primary" %>
                <%= button_to "Delete", todo_list_todo_path(@todo_list, todo), 
                    method: :delete, 
                    form: { data: { turbo_confirm: "Are you sure?" } },
                    class: "btn btn-sm btn-danger" %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <p>No todos in this list yet.</p>
    <% end %>
  </div>

  <div class="actions">
    <%= link_to "New Todo", new_todo_list_todo_path(@todo_list), class: "btn btn-primary" %>
    <%= link_to "Edit", edit_todo_list_path(@todo_list), class: "btn btn-warning" %>
    <%= button_to "Delete", todo_list_path(@todo_list), 
        method: :delete, 
        form: { data: { turbo_confirm: "Are you sure?" } },
        class: "btn btn-danger" %>
    <%= link_to "Back to Lists", todo_lists_path, class: "btn btn-secondary" %>
  </div>
</div>
```

---

## Step 5: Run All Tests

```bash
bundle exec rspec spec/requests/todo_lists/todos_spec.rb
```

All nested todos tests should pass! ✓

Then run all request tests:

```bash
bundle exec rspec spec/requests/
```

Not all should pass!

---

## Step 6: Update Root Path Test

The root path now points to TodoLists instead of Todos. Update the test in `spec/requests/todos_spec.rb`:

Change this:
```ruby
describe "root path" do
  it "redirects to todos index" do
    get root_path
    expect(response).to redirect_to(todos_path)
  end
end
```

To this:
```ruby
describe "root path" do
  it "displays todo lists on root path" do
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Todo Lists")
  end
end
```

**What changed:**
- Root path now displays TodoLists index
- Test verifies the response is successful (200 status)
- Test verifies "Todo Lists" heading is present on the page

Run all tests:

```bash
bundle exec rspec spec/requests/
```

All tests should pass! ✅

---

## Step 7: Test manually

Start the Rails server:

```bash
rails server
```

Visit your browser:
- `http://localhost:3000` - Now shows TodoLists index (changed root route)
- Click "New Todo List" and create a list
- Click "View" to see the list details
- Click "New Todo" to add todos to the list
- Click todo title to see details
- Delete todos from the list

Everything should work! ✅

---

## Understanding Nested Controllers

The controller uses `module TodoLists` to namespace it:

```ruby
module TodoLists
  class TodosController < ApplicationController
    # ...
  end
end
```

**What this does:**
- Keeps nested controller separate from standalone controller
- File location: `app/controllers/todo_lists/todos_controller.rb`
- Routing: `/todo_lists/:todo_list_id/todos/:id`
- Maintains relationship: todos belong to a specific list

---

## Understanding `build` vs `create`

```ruby
# In nested controller:
@todo = @todo_list.todos.build(todo_params)
```

**Why `build` instead of `new`?**
- `build` automatically sets `todo_list_id`
- Creates a todo associated with the list
- Equivalent to: `Todo.new(todo_params.merge(todo_list_id: @todo_list.id))`

**Why `@todo_list.todos.find` instead of `Todo.find`?**
- Ensures we only find todos from this specific list
- Returns 404 if todo doesn't belong to the list
- Prevents accessing todos from other lists

---

## 🎯 Completion Checklist

- [ ] Updated root route to `todo_lists#index`
- [ ] Created request specs for nested todos
- [ ] Generated `TodoLists::TodosController`
- [ ] Implemented index, new, create, show, destroy actions
- [ ] Created all 3 nested todos views
- [ ] Updated TodoList show view with links
- [ ] All nested todos tests passing
- [ ] Tested manually in browser
- [ ] Root path now shows TodoLists
- [ ] Can create, view, delete todos in a list

## 📝 What You've Learned

- Nested controllers with module namespacing
- Nested routing in practice
- Using `build` to associate models
- Scoped queries (`@todo_list.todos`)
- Parent-child relationships in controllers
- Protecting nested resources
- RESTful design with nested resources

## 🔍 Key Methods

| Method | Purpose |
|--------|---------|
| `@todo_list.todos.build` | Create new todo associated with list |
| `@todo_list.todos.find` | Find todo belonging to this list |
| `todo_list_todo_path(@todo_list, @todo)` | Generate nested route |
| `new_todo_list_todo_path(@todo_list)` | Generate nested new path |

## 🚀 Next Steps

- Create `TodoLists::TodosController` edit and update actions
- Add bulk operations (mark all complete, delete all)
- Add sorting and filtering
- Add todo completion toggle from the list view

---

**Lesson Status**: ✅ Complete
**Time Estimate**: 30-40 minutes
**Difficulty**: Intermediate