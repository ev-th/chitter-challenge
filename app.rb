require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'lib/peep_repository'
require_relative 'lib/user_repository'
require_relative 'lib/database_connection'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/user_repository'
    also_reload 'lib/peep_repository'
  end

  get '/' do
    peep_repo = PeepRepository.new
    peeps = peep_repo.all
    @peeps = peeps.sort_by(&:time_posted).reverse
    user_repo = UserRepository.new
    @peeps.each { |peep| peep.user = user_repo.find(peep.user_id) }

    erb(:index)
  end

  get '/sign-up' do
    erb(:sign_up)
  end

  get '/new-peep' do
    erb(:new_peep)
  end

  post '/sign-up' do
    user = User.new
    user.email = params[:email]
    user.password = params[:password]
    user.name = params[:name]
    user.username = params[:username]
    repo = UserRepository.new
    repo.create(user)
    erb(:sign_up_success)
  end

  post '/new-peep' do
    peep = Peep.new
    peep.content = params[:content]
    peep.time_posted = params[:time_posted] || Time.new
    peep.user_id = params[:user_id]
    repo = PeepRepository.new
    repo.create(peep)
    erb(:new_peep_success)
  end
end
