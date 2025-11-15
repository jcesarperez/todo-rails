Rails.application.routes.draw do
  resources :todos

  resources :todo_lists do
    resources :todos, module: :todo_lists
  end

  root "todos#index"
end
