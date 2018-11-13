require 'sinatra'
require 'byebug'
require './models/obra_publica.rb'
require './models/persistence_manager.rb'

get '/' do
  index
end





def index
  erb :index
end


private

def obras
  persistence_manager = PersistenceManager.new
  @lista_obras = persistence_manager.lista_obras
  erb :obras
end