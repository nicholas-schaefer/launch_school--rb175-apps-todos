require "sinatra"
require "sinatra/reloader"
require 'sinatra/content_for'
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  session[:lists] ||= []
end

get "/" do
  redirect "/lists"
end

# View all the lists
get "/lists" do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Render the new list form
get "/lists/new" do
  erb :new_list, layout: :layout
end

# Return a boolean true value if a_string is also an integer
def is_i?(a_string)
  !!(a_string =~ /\A[-+]?[0-9]+\z/)
end

# Return a boolean true value if string size is within character range
def within_character_range?(str)
  (1..100).cover? str.size
end

# Return an error message if the list index is invalid. Return nil if the name is valid
def error_for_list_index(index)
  if (!is_i?(index)) || (!(0...@lists.size).cover? index.to_i)
    "list not found"
  end
end

# Return an error message if the todo item is invalid. Return nil if the todo item is valid
def error_for_todo_item(todo)
  if !within_character_range?(todo)
    "Todo item name must be between 1 and 100 characters"
  end
end

# Return an error message if the name is invalid. Return nil if the name is valid
def error_for_list_name(name)
  if !within_character_range?(name)
    "List name must be between 1 and 100 characters"
  elsif session[:lists].any?{ |list| list[:name] == name }
    "List name must be unique"
  end
end

# View single lists
get "/lists/:list_id" do

  @lists = session[:lists]
  @list_id = params[:list_id]

  error = error_for_list_index(@list_id)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    @list = @lists[@list_id.to_i]
    erb :list, layout: :layout
  end
end


# Update an existing todo list
post "/lists/:list_id" do
  list_name = params[:list_name].strip
  @lists = session[:lists]
  @list_id = params[:list_id]
  @list = @lists[@list_id.to_i]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = "The list has been updated."
    redirect "/lists/#{@list_id}"
  end
end

# Adding a new todo to a list
post "/lists/:list_id/todos" do
  @lists = session[:lists]
  @list_id = params[:list_id]
  @todo = params[:todo]
  @list = @lists[@list_id.to_i]
  # params[:todo]

  error = error_for_todo_item(@todo.strip)
  if error
    session[:error] = "Todo must be between 1 and 100 characters."
    erb :list, layout: :layout
  else
    session[:success] = "The todo was added."
    @list[:todos] << {name: @todo.strip, completed: false}
    @todo = nil
    erb :list, layout: :layout
    # erb "<pre>#{@list}</pre>"
    # redirect "/lists/#{@list_id}"
  end
end

# Delete an existing to do list
post "/lists/:list_id/destroy" do

  @lists = session[:lists]
  @list_id = params[:list_id]

  error = error_for_list_index(@list_id)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else

    @lists.delete_at(@list_id.to_i)
    session[:success] = "The list has been deleted."
    redirect "/lists"
  end
end

# Edit an existing to do list
get "/lists/:list_id/edit" do

  @lists = session[:lists]
  @list_id = params[:list_id]

  error = error_for_list_index(@list_id)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    @list = @lists[@list_id.to_i]
    erb :edit_list, layout: :layout
  end
end

# Create a new list
post "/lists" do
    list_name = params[:list_name].strip

    error = error_for_list_name(list_name)
    if error
      session[:error] = error
      erb :new_list, layout: :layout
    else
      session[:lists] << { name: list_name, todos: [] }
      session[:success] = "The list has been created."
      redirect "/lists"
    end
end
