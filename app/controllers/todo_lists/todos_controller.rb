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
