require 'sinatra'
require 'byebug'
require './models/obra_publica.rb'
require './models/persistence_manager.rb'
require './models/input_exception.rb'

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
  @success = false
  persistence_manager = PersistenceManager.new
  loop do 
    @id = rand(50000)
    #byebug
    break if persistence_manager.obra(@id).nil?
  end
  begin
    @nueva_obra = ObraPublica.new(@id, params['nombre'], params['etapa'], params['tipo'], params['area'], params['descripcion'], params['monto'], 
    params['comuna'], params['barrio'], params['direccion'], params['fecha_inicio'], params['fecha_fin_planeada'], params['fecha_fin_real'], params['avance'], params['imagen'])
    persistence_manager = PersistenceManager.new
    persistence_manager.crear_obra @nueva_obra
  rescue => exception
    @errors << exception.message
  end
  if @errors.empty?
    @success = true
    vista_obra(@id)
  else
    erb :nueva_obra
  end
end

get '/lista_obras' do
  obras
end

get '/vista_obra/:id' do
  @title = 'OP -CABA [Vista de obra]'
  vista_obra(params[:id])
end

get '/modificar_obra/:id' do
  @title = 'OP -CABA [Modificar obra]'
  @errors = []
  @etapas = %w[En\ Ejecución En\ Licitación En\ Proyecto Finalizada]
  persistence_manager = PersistenceManager.new
  begin
    @obra_actual = persistence_manager.obra(params[:id])
  rescue => exception
    @errors << exception.message
  end
  erb :modificar_obra
end

put '/modificar_obra/:id' do
  @errors = []
  persistence_manager = PersistenceManager.new

  begin
    @obra = persistence_manager.obra(params[:id])
    @obra.nombre = params[:nombre]
    @obra.etapa = params[:etapa]
    @obra.tipo = params[:tipo]
    @obra.area_responsable = params[:area]
    @obra.descripcion = params[:descripcion]
    @obra.monto_contrato = params[:monto]
    @obra.comuna = params[:comuna]
    @obra.barrio = params[:barrio]
    @obra.direccion = params[:direccion]
    @obra.fecha_inicio = params[:fecha_inicio]
    @obra.fecha_fin_planeada = params[:fecha_fin_planeada]
    @obra.fecha_fin_real = params[:fecha_fin_real]
    @obra.porcentaje_avance = params[:avance]
    @obra.imagen = params[:imagen]
    persistence_manager.modificar_obra(@obra)
  rescue => exception
    @errors << exception.message
  end

  erb :vista_obra
end

delete '/obra/:id' do
  @errors = []
  @success_delete = false
  persistence_manager = PersistenceManager.new
  begin
    persistence_manager.eliminar_obra(params[:id])
  rescue => exception
    @errors << exception.message
  end
  if @errors.empty?
    @success_delete = true
  end
  obras
end  

get '/contacto' do
  @title = 'OP -CABA [Contacto]'
  erb :contacto
end

def index
  @title = 'Obra Pública -CABA'
  @errors = []
  @success = false
  persistence_manager = PersistenceManager.new
  @lista_de_obras = persistence_manager.lista_obras
  if @lista_de_obras.empty?
    begin
      parser = ObrasParser.new('./obras.csv')
      obras = parser.parse
      obras.each do |obra| persistence_manager.crear_obra obra
      end
    rescue => exception
      @errors << exception.message
    end
    if @errors.empty?
      @success = true
    end
  end
  erb :index
end


private

def obras
  @title = 'OP -CABA [Lista de obras]'
  persistence_manager = PersistenceManager.new
  @lista_de_obras = persistence_manager.lista_obras
  erb :lista_obras
end

def vista_obra(id)
  #byebug
  persistence_manager = PersistenceManager.new
  @obra = persistence_manager.obra(id)
  erb :vista_obra
end