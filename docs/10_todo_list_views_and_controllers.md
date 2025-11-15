# Lesson 10: TodoList Views and Controllers

**Objective**: Create HTTP endpoints and views for managing TodoLists and their associated Todos.

**What we'll build**: A RESTful TodoList controller with views, plus nested routes to manage Todos within TodoLists.

## Understanding Nested Routes

We need to handle two types of routes:

**1. TodoList routes (standalone):**
```
GET    /todo_lists           → index (list all lists)
GET    /todo_lists/new       → new (create form)
POST   /todo_lists           → create (save new list)
GET    /todo_lists/:id       → show (view list details)
GET    /todo_lists/:id/edit  → edit (edit form)
PATCH  /todo_lists/:id       → update (save changes)
DELETE /todo_lists/:id       → destroy (delete list)
```

**2. Nested Todos routes (todos within a list):**
```
GET    /todo_lists/:todo_list_id/todos           → index (list todos in list)
GET    /todo_lists/:todo_list_id/todos/new       → new (create form)
POST   /todo_lists/:todo_list_id/todos           → create (save new todo)
GET    /todo_lists/:todo_list_id/todos/:id       → show (view todo)
GET    /todo_lists/:todo_list_id/todos/:id/edit  → edit (edit form)
PATCH  /todo_lists/:todo_list_id/todos/:id       → update (save changes)
DELETE /todo_lists/:todo_list_id/todos/:id       → destroy (delete todo)
```

**Note:** Standalone Todos (without a list) are still accessible at `/todos` routes from Lesson 8.

---

## Step 1: Set Up Nested Routes

Edit `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  resources :todos
  
  resources :todo_lists do
    resources :todos, module: :todo_lists
  end
  
  root "todos#index"
end
```

**What this does:**
- `resources :todos` - Standalone todos (from Lesson 8)
- `resources :todo_lists { resources :todos }` - Nested todos under todo_lists
- `module: :todo_lists` - Puts nested todos controller in `app/controllers/todo_lists/todos_controller.rb`

This generates all nested routes automatically.

---

## Step 2: Write Request Specs for TodoList (Red Phase)

Create the request specs:

```bash
mkdir -p spec/requests
touch spec/requests/todo_lists_spec.rb
```

Edit `spec/requests/todo_lists_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe "TodoLists", type: :request do
  describe "GET /todo_lists (index)" do
    it "returns successful response" do
      get todo_lists_path
      expect(response).to have_http_status(:ok)
    end

    it "renders index template" do
      get todo_lists_path
      expect(response).to render_template(:index)
    end

    it "assigns all todo_lists to @todo_lists" do
      list1 = TodoList.create!(title: "List 1")
      list2 = TodoList.create!(title: "List 2")

      get todo_lists_path

      expect(assigns(:todo_lists)).to eq([list1, list2])
    end

    it "displays todo_lists on page" do
      list = TodoList.create!(title: "Shopping")
      get todo_lists_path
      expect(response.body).to include("Shopping")
    end
  end

  describe "GET /todo_lists/new (new)" do
    it "returns successful response" do
      get new_todo_list_path
      expect(response).to have_http_status(:ok)
    end

    it "renders new template" do
      get new_todo_list_path
      expect(response).to render_template(:new)
    end

    it "assigns a new todo_list to @todo_list" do
      get new_todo_list_path
      expect(assigns(:todo_list)).to be_a_new(TodoList)
    end
  end

  describe "POST /todo_lists (create)" do
    it "creates a new todo_list with valid params" do
      expect {
        post todo_lists_path, params: { todo_list: { title: "New List" } }
      }.to change(TodoList, :count).by(1)
    end

    it "redirects to show page on success" do
      post todo_lists_path, params: { todo_list: { title: "New List" } }
      expect(response).to redirect_to(todo_list_path(TodoList.last))
    end

    it "sets flash success message" do
      post todo_lists_path, params: { todo_list: { title: "New List" } }
      expect(flash[:notice]).to eq("TodoList was successfully created.")
    end

    it "does not create with invalid params" do
      expect {
        post todo_lists_path, params: { todo_list: { title: "" } }
      }.not_to change(TodoList, :count)
    end

    it "re-renders new template on validation failure" do
      post todo_lists_path, params: { todo_list: { title: "" } }
      expect(response).to render_template(:new)
    end

    it "displays error messages on failure" do
      post todo_lists_path, params: { todo_list: { title: "" } }
      expect(response.body).to include("Title can't be blank")
    end
  end

  describe "GET /todo_lists/:id (show)" do
    let(:todo_list) { TodoList.create!(title: "My List") }

    it "returns successful response" do
      get todo_list_path(todo_list)
      expect(response).to have_http_status(:ok)
    end

    it "renders show template" do
      get todo_list_path(todo_list)
      expect(response).to render_template(:show)
    end

    it "assigns the todo_list to @todo_list" do
      get todo_list_path(todo_list)
      expect(assigns(:todo_list)).to eq(todo_list)
    end

    it "displays the todo_list title" do
      get todo_list_path(todo_list)
      expect(response.body).to include(todo_list.title)
    end

    it "returns 404 for non-existent todo_list" do
      get todo_list_path(999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /todo_lists/:id/edit (edit)" do
    let(:todo_list) { TodoList.create!(title: "My List") }

    it "returns successful response" do
      get edit_todo_list_path(todo_list)
      expect(response).to have_http_status(:ok)
    end

    it "renders edit template" do
      get edit_todo_list_path(todo_list)
      expect(response).to render_template(:edit)
    end

    it "assigns the todo_list to @todo_list" do
      get edit_todo_list_path(todo_list)
      expect(assigns(:todo_list)).to eq(todo_list)
    end
  end

  describe "PATCH /todo_lists/:id (update)" do
    let(:todo_list) { TodoList.create!(title: "Original") }

    it "updates the todo_list with valid params" do
      patch todo_list_path(todo_list), params: { todo_list: { title: "Updated" } }
      expect(todo_list.reload.title).to eq("Updated")
    end

    it "redirects to show page on success" do
      patch todo_list_path(todo_list), params: { todo_list: { title: "Updated" } }
      expect(response).to redirect_to(todo_list_path(todo_list))
    end

    it "sets flash success message" do
      patch todo_list_path(todo_list), params: { todo_list: { title: "Updated" } }
      expect(flash[:notice]).to eq("TodoList was successfully updated.")
    end

    it "does not update with invalid params" do
      patch todo_list_path(todo_list), params: { todo_list: { title: "" } }
      expect(todo_list.reload.title).to eq("Original")
    end

    it "re-renders edit template on failure" do
      patch todo_list_path(todo_list), params: { todo_list: { title: "" } }
      expect(response).to render_template(:edit)
    end

    it "returns 404 for non-existent todo_list" do
      patch todo_list_path(999), params: { todo_list: { title: "Updated" } }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /todo_lists/:id (destroy)" do
    let!(:todo_list) { TodoList.create!(title: "Delete me") }

    it "deletes the todo_list" do
      expect {
        delete todo_list_path(todo_list)
      }.to change(TodoList, :count).by(-1)
    end

    it "redirects to index page" do
      delete todo_list_path(todo_list)
      expect(response).to redirect_to(todo_lists_path)
    end

    it "sets flash success message" do
      delete todo_list_path(todo_list)
      expect(flash[:notice]).to eq("TodoList was successfully destroyed.")
    end

    it "also deletes associated todos" do
      todo1 = todo_list.todos.create!(title: "Task 1")
      todo2 = todo_list.todos.create!(title: "Task 2")

      delete todo_list_path(todo_list)

      expect(Todo.where(id: [todo1.id, todo2.id])).to be_empty
    end

    it "returns 404 for non-existent todo_list" do
      delete todo_list_path(999)
      expect(response).to have_http_status(:not_found)
    end
  end
end
```

Run the tests to see them fail:

```bash
bundle exec rspec spec/requests/todo_lists_spec.rb
```

You should see many failures. ✓ This is the **Red** phase.

---

## Step 3: Generate TodoListsController (Green Phase)

```bash
rails generate controller TodoLists index show new edit --skip-test
```

This creates:
- `app/controllers/todo_lists_controller.rb`
- Views directory structure

Edit `app/controllers/todo_lists_controller.rb`:

```ruby
class TodoListsController < ApplicationController
  before_action :set_todo_list, only: [:show, :edit, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @todo_lists = TodoList.all
  end

  def new
    @todo_list = TodoList.new
  end

  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      redirect_to @todo_list, notice: "TodoList was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @todo_list.update(todo_list_params)
      redirect_to @todo_list, notice: "TodoList was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @todo_list.destroy
    redirect_to todo_lists_url, notice: "TodoList was successfully destroyed."
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:title)
  end

  def not_found
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
```

---

## Step 4: Create TodoList Views

### Create `app/views/todo_lists/index.html.erb`:

```erb
<div class="container">
  <h1>Todo Lists</h1>

  <div class="todo-lists">
    <% if @todo_lists.any? %>
      <table class="table">
        <thead>
          <tr>
            <th>Title</th>
            <th>Todos</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <% @todo_lists.each do |list| %>
            <tr>
              <td><%= link_to list.title, todo_list_path(list) %></td>
              <td>
                <span class="badge"><%= list.todos.count %></span>
              </td>
              <td>
                <%= link_to "View", todo_list_path(list), class: "btn btn-sm btn-primary" %>
                <%= link_to "Edit", edit_todo_list_path(list), class: "btn btn-sm btn-warning" %>
                <%= button_to "Delete", todo_list_path(list), 
                    method: :delete, 
                    form: { data: { turbo_confirm: "Are you sure?" } },
                    class: "btn btn-sm btn-danger" %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    <% else %>
      <p>No todo lists yet. <%= link_to "Create one!", new_todo_list_path %></p>
    <% end %>
  </div>

  <%= link_to "New Todo List", new_todo_list_path, class: "btn btn-primary" %>
  <%= link_to "Back to Todos", todos_path, class: "btn btn-secondary" %>
</div>
```

### Create `app/views/todo_lists/new.html.erb`:

```erb
<div class="container">
  <h1>New Todo List</h1>

  <%= form_with(model: @todo_list, local: true) do |form| %>
    <% if @todo_list.errors.any? %>
      <div id="error_explanation" class="alert alert-danger">
        <h4><%= pluralize(@todo_list.errors.count, "error") %> prohibited this todo list from being saved:</h4>
        <ul>
          <% @todo_list.errors.full_messages.each do |message| %>
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
      <%= form.submit "Create Todo List", class: "btn btn-primary" %>
      <%= link_to "Cancel", todo_lists_path, class: "btn btn-secondary" %>
    </div>
  <% end %>
</div>
```

### Create `app/views/todo_lists/edit.html.erb`:

```erb
<div class="container">
  <h1>Edit Todo List</h1>

  <%= form_with(model: @todo_list, local: true) do |form| %>
    <% if @todo_list.errors.any? %>
      <div id="error_explanation" class="alert alert-danger">
        <h4><%= pluralize(@todo_list.errors.count, "error") %> prohibited this todo list from being saved:</h4>
        <ul>
          <% @todo_list.errors.full_messages.each do |message| %>
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
      <%= form.submit "Update Todo List", class: "btn btn-primary" %>
      <%= link_to "Cancel", @todo_list, class: "btn btn-secondary" %>
    </div>
  <% end %>
</div>
```

### Create `app/views/todo_lists/show.html.erb`:

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
              <td><%= todo.title %></td>
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
      <p>No todos in this list yet.</p>
    <% end %>
  </div>

  <div class="actions">
    <%= link_to "Edit", edit_todo_list_path(@todo_list), class: "btn btn-primary" %>
    <%= button_to "Delete", todo_list_path(@todo_list), 
        method: :delete, 
        form: { data: { turbo_confirm: "Are you sure?" } },
        class: "btn btn-danger" %>
    <%= link_to "Back to Lists", todo_lists_path, class: "btn btn-secondary" %>
  </div>
</div>
```

---

## Step 5: Run Tests

```bash
bundle exec rspec spec/requests/todo_lists_spec.rb
```

All tests should pass! ✓ This is the **Green** phase.

---

## Step 6: Test Manually

Start the Rails server:

```bash
rails server
```

Visit your browser:
- `http://localhost:3000/todo_lists` - List all TodoLists
- Create, edit, and delete TodoLists
- View todos in each list

Everything should work! ✅

---

## Understanding Nested Routes

The routes defined in `config/routes.rb`:

```ruby
resources :todo_lists do
  resources :todos, module: :todo_lists
end
```

**What this creates:**

```
GET    /todo_lists/:todo_list_id/todos        → TodoLists::TodosController#index
POST   /todo_lists/:todo_list_id/todos        → TodoLists::TodosController#create
GET    /todo_lists/:todo_list_id/todos/new    → TodoLists::TodosController#new
GET    /todo_lists/:todo_list_id/todos/:id    → TodoLists::TodosController#show
PATCH  /todo_lists/:todo_list_id/todos/:id    → TodoLists::TodosController#update
DELETE /todo_lists/:todo_list_id/todos/:id    → TodoLists::TodosController#destroy
GET    /todo_lists/:todo_list_id/todos/:id/edit → TodoLists::TodosController#edit
```

**Key points:**
- `module: :todo_lists` - Controller lives in `app/controllers/todo_lists/todos_controller.rb`
- Routes are nested under `todo_list_id`
- We'll implement `TodoLists::TodosController` in a future lesson

---

## 🎯 Completion Checklist

- [ ] Set up nested routes in `config/routes.rb`
- [ ] Created request specs for TodoLists
- [ ] Generated TodoListsController
- [ ] Implemented all 7 CRUD actions
- [ ] Created all 4 views (index, new, edit, show)
- [ ] All TodoList request tests passing
- [ ] Tested manually in browser
- [ ] TodoLists CRUD operations working
- [ ] Delete cascades to associated Todos

## 📝 What You've Learned

- Nested routing in Rails
- RESTful routes with nested resources
- Module namespacing for controllers
- Managing parent-child relationships in views
- Displaying related data
- Cascading deletes in action
- Complex request specs

## 🔍 Key Concepts

**Nested Routes:**
- Parent resource: `todo_lists`
- Child resource: `todos` (nested under `todo_lists`)
- Generates routes like `/todo_lists/:todo_list_id/todos/:id`
- Scopes todos to their parent list in URL

**Module Namespacing:**
- `module: :todo_lists` puts controller in subdirectory
- Creates `app/controllers/todo_lists/todos_controller.rb`
- Helps organize controllers by resource relationship

---

## 🚀 Next Steps

- Create `TodoLists::TodosController` for managing todos within lists
- Add filtering and sorting to todo lists
- Implement bulk operations (mark all as complete, delete all, etc.)
- Add search functionality

---

**Lesson Status**: ✅ Complete
**Time Estimate**: 30-40 minutes
**Difficulty**: Intermediate