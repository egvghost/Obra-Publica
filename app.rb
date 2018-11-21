require 'sinatra'
require 'byebug'
require './models/obra_publica.rb'
require './models/persistence_manager.rb'

get '/' do
  index
end

get '/nueva_obra' do
  @title = 'OP -CABA [Nueva obra]'
  @etapas = %w[En\ Ejecución En\ Licitación En\ Proyecto Finalizada]
  erb :nueva_obra
end

get '/contacto' do
  @title = 'OP -CABA [Contacto]'
  erb :contacto
end

def index
  @title = 'Obra Pública -CABA'
  @etapas = %w[En\ Ejecución En\ Licitación En\ Proyecto Finalizada]
  erb :index
end


private

def obras
  persistence_manager = PersistenceManager.new
  @lista_obras = persistence_manager.lista_obras
  erb :obras
end