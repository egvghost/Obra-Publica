require 'sinatra'
require 'byebug'
require 'date'
require 'pill_chart'
require 'gruff'
require './models/obra_publica.rb'
require './models/persistence_manager.rb'
require './models/input_exception.rb'

get '/' do
  @errors = []
  index
end

get '/nueva_obra' do
  @title = 'OP -CABA [Nueva obra]'
  @nueva_obra_selected_in_nav = true
  @etapas = %w[En\ Ejecución En\ Licitación En\ Proyecto Finalizada]
  erb :nueva_obra
end

post '/nueva_obra' do
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
    @nueva_obra = ObraPublica.new(@id, params[:nombre], params[:etapa], params[:tipo], params[:area], params[:descripcion], params[:monto], 
    params[:comuna], params[:barrio], params[:direccion], params[:fecha_inicio], params[:fecha_fin_planeada], params[:fecha_fin_real], params[:avance], params[:imagen])
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
  @success_delete = false
  persistence_manager = PersistenceManager.new
  begin
    @obra = persistence_manager.obra(params[:id])
    @obra = ObraPublica.new(params[:id], params[:nombre], params[:etapa], params[:tipo], params[:area], 
    params[:descripcion], params[:monto], params[:comuna], params[:barrio], params[:direccion], 
    params[:fecha_inicio], params[:fecha_fin_planeada], params[:fecha_fin_real], params[:avance], params[:imagen])
    persistence_manager.modificar_obra(@obra)
  rescue => exception
    @errors << exception.message
  end
  if @errors.empty?
    @success = true
  end
  erb :vista_obra
end

delete '/obra/:id' do
  @errors_del = []
  @success_delete = false
  persistence_manager = PersistenceManager.new
  begin
    persistence_manager.eliminar_obra(params[:id])
  rescue => exception
    @errors_del << exception.message
  end
  if @errors_del.empty?
    @success_delete = true
  end
  obras
end

get '/estadisticas' do
  @title = 'OP -CABA [Estadísticas]'
  @estadisticas_selected_in_nav = true
  @errors = []
  @obras_comuna = Hash.new(0)
  @cant_obras_terminadas = Hash.new(0)
  obras_año = Hash.new(0)
  @tipo_obra = Hash.new(0)
  @obras_excedidas = []
  @excesos = {}
  @porcentaje_excesos = {}
  porcentaje_terminadas = {}
  tiempo_obras = {}
  obras_terminadas = []
  @graphs = {}
  persistence_manager = PersistenceManager.new
  #byebug
  begin
    @lista_de_obras = persistence_manager.lista_obras
    @lista_de_obras.each do |obra| 
      @tipo_obra[obra.tipo] += 1
      @obras_comuna["Comuna #{obra.comuna}"] += 1
      unless obra.fecha_fin_real.empty?
        @cant_obras_terminadas["Comuna #{obra.comuna}"] += 1
        obras_año["Año #{Date.parse(obra.fecha_fin_real).year}"] += 1
        if obra.fecha_fin_real > obra.fecha_fin_planeada then 
          @obras_excedidas << obra
          @excesos[obra] = (Date.parse(obra.fecha_fin_real)-Date.parse(obra.fecha_fin_planeada)).to_i
          @porcentaje_excesos[obra] = ((((Date.parse(obra.fecha_fin_real)-Date.parse(obra.fecha_inicio)).to_f / 
          (Date.parse(obra.fecha_fin_planeada)-Date.parse(obra.fecha_inicio)).to_f) - 1) * 100).to_i
        end
        tiempo_obras[obra] = (Date.parse(obra.fecha_fin_real)-Date.parse(obra.fecha_inicio)).to_i
        obras_terminadas << obra
      end
      porcentaje_terminadas["Comuna #{obra.comuna}"] = @cant_obras_terminadas["Comuna #{obra.comuna}"] * 100 / @obras_comuna["Comuna #{obra.comuna}"]
      colors = {
        'background' => '#b9d2ad', # the background colour
        'foreground' => '#38761d', # the pill color when it's a simple pill (not a state pill)
      }
      @graphs["Comuna #{obra.comuna}"] = PillChart::SimplePillChart.new(10, 100, porcentaje_terminadas["Comuna #{obra.comuna}"], 100, :simple, colors)
    end
    @exceso_promedio_dias = @excesos.values.sum/@excesos.size
    @exceso_promedio_porcentaje = @porcentaje_excesos.values.sum/@porcentaje_excesos.size
    @obras_comuna_max = @obras_comuna.select {|k,v| v == @obras_comuna.values.max}
    @obras_año_max = obras_año.select {|k,v| v == obras_año.values.max}
    @comunas_mas_obras_terminadas = @cant_obras_terminadas.sort_by {|k,v| -v}
    @obras_mas_largas = tiempo_obras.sort_by {|k,v| -v}
    @obras_mas_caras = obras_terminadas.sort_by {|obras| -obras.monto_contrato}
    g = Gruff::Pie.new
    g.title = 'Distribución porcentual por tipo de obra'
    @tipo_obra.each do |tipo|
      g.data(tipo[0], tipo[1])
    end
    g.theme = {:colors => %w(yellow green red darkblue orange purple lightblue brown), :marker_color => 'black', :background_colors => %w(white grey)}
    g.write("public/images/chart.png")
  rescue => exception
    @errors << exception.message
  end
  if @errors.empty?
    erb :estadisticas
  else
    index
  end
end

post '/consulta_obras' do
  @title = 'OP -CABA [Consulta]'
  @errors = []
  @obras_año = []
  @año = params[:año]
  @opcion = params[:opcion]
  persistence_manager = PersistenceManager.new
  #byebug
  begin
    @lista_de_obras = persistence_manager.lista_obras
    case @opcion
      when 'iniciadas' then 
        @lista_de_obras.each do |obra| 
          if ! obra.fecha_inicio.empty?
            if (Date.parse(obra.fecha_inicio).year).to_s == @año then @obras_año << obra
            end
          end
        end
      when 'finalizadas' then
        @lista_de_obras.each do |obra| 
          if ! obra.fecha_fin_real.empty?
            if (Date.parse(obra.fecha_fin_real).year).to_s == @año then @obras_año << obra
            end
          end
        end
    end
  rescue => exception
    @errors << exception.message
  end
  erb :consulta_obras
end

get '/enunciado' do
  @title = 'OP -CABA [Enunciado TP]'
  @enunciado_selected_in_nav = true
  erb :enunciado
end

get '/contacto' do
  @title = 'OP -CABA [Contacto]'
  @contacto_selected_in_nav = true
  erb :contacto
end


def index
  @title = 'Obra Pública -CABA'
  @inicio_selected_in_nav = true
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

def obras
  @title = 'OP -CABA [Lista de obras]'
  @lista_obras_selected_in_nav = true
  @errors = []
  persistence_manager = PersistenceManager.new
  begin
    @lista_de_obras = persistence_manager.lista_obras.sort_by {|item| item.fecha_inicio}
    @lista_de_obras.reverse!
  rescue => exception
    @errors << exception.message
  end
  if @errors.empty?
    erb :lista_obras
  else
    index
  end
end

def vista_obra(id)
  @title = 'OP -CABA [Vista de obra]'
  @errors = []
  persistence_manager = PersistenceManager.new
  begin
    @obra = persistence_manager.obra(id)
  rescue => exception
    @errors << exception.message
  end
  if @errors.empty?
    erb :vista_obra
  else
    index
  end
end

