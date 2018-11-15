require 'date'
require 'byebug'

class ObraPublica

  attr_reader :id
  attr_accessor :nombre, :etapa, :tipo, :area_responsable, :descripcion, :monto_contrato, 
  :comuna, :barrio, :direccion, :fecha_inicio, :fecha_fin_planeada, :fecha_fin_real, :porcentaje_avance, :imagen

  def initialize(id, nombre, etapa, tipo, area_responsable, descripcion, monto_contrato, 
    comuna, barrio, direccion, fecha_inicio, fecha_fin_planeada, fecha_fin_real, porcentaje_avance, imagen)

    @etapas = ['En Ejecución', 'En Licitación', 'En Proyecto', 'Finalizada']
    raise InputException.new('La etapa ingresada no coincide con las opciones permitidas') unless @etapas.include? etapa
    raise InputException.new('El porcentaje de avance ingresado no est{a permitido') unless (porcentaje_avance >= 0 && porcentaje_avance <= 100)
    raise InputException.new('El monto ingresado no puede ser negativo') unless monto_contrato >= 0
    raise InputException.new('El número de comuna debe estar entre 1 y 15') unless (comuna >= 1 && comuna <=15)
    raise InputException.new('La descripción no puede contener más de 2000 caracteres') unless descripcion.length <= 2000
    #raise InputException.new('El formato de fecha ingresado no es válido') unless...
    #raise InputException.new('La fecha final planificada debe ser posterior a la fecha de inicio') unless fecha_fin_planeada > fecha_inicio
    #raise InputException.new('La fecha final real debe ser posterior a la fecha de inicio') unless fecha_fin_real > fecha_inicio
    @parser = ObrasParser.new('./models/obras.csv')
    @obras = @parser.parse
    if etapa == 'Finalizada' then 
      raise InputException.new('Toda obra FINALIZADA debe tener un porcentaje de avance del 100% y una fecha de finalización real acorde') unless (porcentaje_avance == 100 && ! fecha_fin_real.empty?)
    end
    if porcentaje_avance == 100 then 
      raise InputException.new('El 100% de avance sólo puede ser utilizado en obras FINALIZADAS') unless etapa == 'Finalizada'
    end
    if ! fecha_fin_real.empty? then 
      raise InputException.new('La fecha de finalización real sólo está disponible para obras FINALIZADAS') unless etapa == 'Finalizada'
    end
  end

end