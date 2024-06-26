Amber::Server.configure do
  pipeline :web do
    # Plug is the method to use connect a pipe (middleware)
    # A plug accepts an instance of HTTP::Handler
    # plug Amber::Pipe::PoweredByAmber.new
    # plug Amber::Pipe::ClientIp.new(["X-Forwarded-For"])
    plug Citrine::I18n::Handler.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::Flash.new
    plug Amber::Pipe::CSRF.new
  end

  pipeline :api do
    # plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::CORS.new
  end

  # All static content will run these transformations
  pipeline :static do
    # plug Amber::Pipe::PoweredByAmber.new
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Static.new("./public")
  end

  routes :web do
    get "/", DiskController, :index

    get "/files/search", FilesController, :search
    get "/files/search/:query", FilesController, :search

    get "/duplication/needed", DuplicationsController, :need_duplication

    resources "disks", DiskController, except: [:destroy]
    resources "paths", PathsController, only: [:show, :edit, :update]
    resources "tags", TagsController, only: [:index, :show]
    resources "files", FilesController, only: [:show]

    resources "move/tags", Move::TagsController, only: [:index, :show]

    # # tools for helping move content to maintain proper redundancy
    # namespace "move" do
    #   # resources "tags", Move::TagsController, only: [:index]
    #   get "/tags", Move::TagsController, :index
    # end
  end

  routes :api do
  end

  routes :static do
    # Each route is defined as follow
    # verb resource : String, controller : Symbol, action : Symbol
    get "/*", Amber::Controller::Static, :index
  end
end
