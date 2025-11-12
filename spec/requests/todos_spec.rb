require "rails_helper"

RSpec.describe "Todos", type: :request do
  describe "GET /todos (index)" do
    it "returns successful response" do
      get todos_path
      expect(response).to have_http_status(:ok)
    end

    it "displays page title" do
      get todos_path
      expect(response.body).to include("<h1>Todos</h1>")
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

    it "shows new todo link" do
      get todos_path
      expect(response.body).to include("New Todo")
    end

    it "displays empty message when no todos" do
      get todos_path
      expect(response.body).to include("No todos yet")
    end
  end

  describe "GET /todos/new (new)" do
    it "returns successful response" do
      get new_todo_path
      expect(response).to have_http_status(:ok)
    end

    it "displays create form" do
      get new_todo_path
      expect(response.body).to include("New Todo")
    end

    it "displays title input field" do
      get new_todo_path
      expect(response.body).to include("title")
    end
  end

  describe "POST /todos (create)" do
    it "creates a new todo with valid params" do
      expect {
        post todos_path, params: {todo: {title: "New task"}}
      }.to change(Todo, :count).by(1)
    end

    it "redirects to show page on success" do
      post todos_path, params: {todo: {title: "New task"}}
      expect(response).to redirect_to(todo_path(Todo.last))
    end

    it "sets flash success message" do
      post todos_path, params: {todo: {title: "New task"}}
      expect(flash[:notice]).to eq("Todo was successfully created.")
    end

    it "does not create todo with invalid params" do
      expect {
        post todos_path, params: {todo: {title: ""}}
      }.not_to change(Todo, :count)
    end

    it "re-renders new template on validation failure" do
      post todos_path, params: {todo: {title: ""}}
      expect(response.body).to include("New Todo")
    end

    it "displays error messages on failure" do
      post todos_path, params: {todo: {title: ""}}
      expect(response.body).to include("error prohibited this todo")
    end
  end

  describe "GET /todos/:id (show)" do
    let(:todo) { Todo.create!(title: "Sample task") }

    it "returns successful response" do
      get todo_path(todo)
      expect(response).to have_http_status(:ok)
    end

    it "displays the todo title" do
      get todo_path(todo)
      expect(response.body).to include(todo.title)
    end

    it "displays edit link" do
      get todo_path(todo)
      expect(response.body).to include("Edit")
    end

    it "displays delete link" do
      get todo_path(todo)
      expect(response.body).to include("Delete")
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

    it "displays edit form" do
      get edit_todo_path(todo)
      expect(response.body).to include("Edit Todo")
    end

    it "pre-fills form with current title" do
      get edit_todo_path(todo)
      expect(response.body).to include(todo.title)
    end

    it "displays completed checkbox" do
      get edit_todo_path(todo)
      expect(response.body).to include("completed")
    end
  end

  describe "PATCH /todos/:id (update)" do
    let(:todo) { Todo.create!(title: "Original title") }

    it "updates the todo with valid params" do
      patch todo_path(todo), params: {todo: {title: "Updated title"}}
      expect(todo.reload.title).to eq("Updated title")
    end

    it "redirects to show page on success" do
      patch todo_path(todo), params: {todo: {title: "Updated title"}}
      expect(response).to redirect_to(todo_path(todo))
    end

    it "sets flash success message" do
      patch todo_path(todo), params: {todo: {title: "Updated title"}}
      expect(flash[:notice]).to eq("Todo was successfully updated.")
    end

    it "updates completed status" do
      patch todo_path(todo), params: {todo: {completed: true}}
      expect(todo.reload.completed).to be(true)
    end

    it "does not update with invalid params" do
      patch todo_path(todo), params: {todo: {title: ""}}
      expect(todo.reload.title).to eq("Original title")
    end

    it "re-renders edit template on failure" do
      patch todo_path(todo), params: {todo: {title: ""}}
      expect(response.body).to include("Edit Todo")
    end

    it "displays error messages on failure" do
      patch todo_path(todo), params: {todo: {title: ""}}
      expect(response.body).to include("error prohibited this todo")
    end

    it "returns 404 for non-existent todo" do
      patch todo_path(999), params: {todo: {title: "Updated"}}
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
    it "displays todos list on root path" do
      get root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<h1>Todos</h1>")
    end
  end
end
