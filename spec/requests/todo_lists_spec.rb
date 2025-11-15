require "rails_helper"

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
        post todo_lists_path, params: {todo_list: {title: "New List"}}
      }.to change(TodoList, :count).by(1)
    end

    it "redirects to show page on success" do
      post todo_lists_path, params: {todo_list: {title: "New List"}}
      expect(response).to redirect_to(todo_list_path(TodoList.last))
    end

    it "sets flash success message" do
      post todo_lists_path, params: {todo_list: {title: "New List"}}
      expect(flash[:notice]).to eq("TodoList was successfully created.")
    end

    it "does not create with invalid params" do
      expect {
        post todo_lists_path, params: {todo_list: {title: ""}}
      }.not_to change(TodoList, :count)
    end

    it "re-renders new template on validation failure" do
      post todo_lists_path, params: {todo_list: {title: ""}}
      expect(response).to render_template(:new)
    end

    it "displays error messages on failure" do
      post todo_lists_path, params: {todo_list: {title: ""}}
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
      patch todo_list_path(todo_list), params: {todo_list: {title: "Updated"}}
      expect(todo_list.reload.title).to eq("Updated")
    end

    it "redirects to show page on success" do
      patch todo_list_path(todo_list), params: {todo_list: {title: "Updated"}}
      expect(response).to redirect_to(todo_list_path(todo_list))
    end

    it "sets flash success message" do
      patch todo_list_path(todo_list), params: {todo_list: {title: "Updated"}}
      expect(flash[:notice]).to eq("TodoList was successfully updated.")
    end

    it "does not update with invalid params" do
      patch todo_list_path(todo_list), params: {todo_list: {title: ""}}
      expect(todo_list.reload.title).to eq("Original")
    end

    it "re-renders edit template on failure" do
      patch todo_list_path(todo_list), params: {todo_list: {title: ""}}
      expect(response).to render_template(:edit)
    end

    it "returns 404 for non-existent todo_list" do
      patch todo_list_path(999), params: {todo_list: {title: "Updated"}}
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
