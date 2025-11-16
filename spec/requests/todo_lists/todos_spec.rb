require "rails_helper"

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
        post todo_list_todos_path(todo_list), params: {todo: {title: "New task"}}
      }.to change(todo_list.todos, :count).by(1)
    end

    it "associates the todo with the todo_list" do
      post todo_list_todos_path(todo_list), params: {todo: {title: "New task"}}
      expect(Todo.last.todo_list).to eq(todo_list)
    end

    it "redirects to todo_list show page on success" do
      post todo_list_todos_path(todo_list), params: {todo: {title: "New task"}}
      expect(response).to redirect_to(todo_list_path(todo_list))
    end

    it "sets flash success message" do
      post todo_list_todos_path(todo_list), params: {todo: {title: "New task"}}
      expect(flash[:notice]).to eq("Todo was successfully created.")
    end

    it "does not create with invalid params" do
      expect {
        post todo_list_todos_path(todo_list), params: {todo: {title: ""}}
      }.not_to change(todo_list.todos, :count)
    end

    it "re-renders new template on failure" do
      post todo_list_todos_path(todo_list), params: {todo: {title: ""}}
      expect(response).to render_template(:new)
    end

    it "displays error messages on failure" do
      post todo_list_todos_path(todo_list), params: {todo: {title: ""}}
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
