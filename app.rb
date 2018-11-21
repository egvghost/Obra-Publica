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

post '/nueva_obra' do
  @title = 'OP -CABA [Vista obra]'
  @etapas = %w[En\ Ejecución En\ Licitación En\ Proyecto Finalizada]
  @errors = []
  id = rand(50000)
  @monto = params['monto'].to_f
  @comuna = params['comuna'].to_i
  @avance = params['avance'].to_f
  #byebug
  @nueva_obra = ObraPublica.new(id, params['nombre'], params['etapa'], params['tipo'], params['area'], params['descripcion'], @monto, 
  @comuna, params['barrio'], params['direccion'], params['fecha_inicio'], params['fecha_fin_planeada'], params['fecha_fin_real'], @avance, params['imagen'])
  persistence_manager = PersistenceManager.new
  begin
    persistence_manager.crear_obra @nueva_obra
  rescue => exception
    @errors << exception.message
  end
  if @errors.empty?
    erb :vista_obra
  else
    index
  end
end

get '/ver_obras' do
  @title = 'OP -CABA [Listado de obras]'
  erb :ver_obras
end

get '/contacto' do
  @title = 'OP -CABA [Contacto]'
  erb :contacto
end

def index
  @title = 'Obra Pública -CABA'
  persistence_manager = PersistenceManager.new
  @lista_de_obras = persistence_manager.lista_obras
  if @lista_de_obras.empty?
    parser = ObrasParser.new('./obras.csv')
    obras = parser.parse
    obras.each do |obra| persistence_manager.crear_obra obra
    end
  end
  erb :index
end


private

def obras
  persistence_manager = PersistenceManager.new
  @lista_de_obras = persistence_manager.lista_obras
  erb :obras
end