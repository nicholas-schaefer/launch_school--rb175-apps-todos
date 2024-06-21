require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

# helpers do
#   def in_list_items()
#   end
# end

get "/" do
  redirect "/lists"
end

get "/lists" do
  @lists = [
    {name: "Lunch Groceries", todos:[]},
    {name: "Dinner Groceries", todos:[]}
  ]
  erb :lists, layout: :layout
end
