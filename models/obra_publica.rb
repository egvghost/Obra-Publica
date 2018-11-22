require 'date'
require 'byebug'
require './models/input_exception.rb'
require './models/obras_parser.rb'

class ObraPublica

  attr_reader :id
  attr_accessor :obras, :nombre, :etapa, :tipo, :area_responsable, :descripcion, :monto_contrato, 
  :comuna, :barrio, :direccion, :fecha_inicio, :fecha_fin_planeada, :fecha_fin_real, :porcentaje_avance, :imagen

  def initialize(id, nombre, etapa, tipo, area_responsable, descripcion, monto_contrato, 
    comuna, barrio, direccion, fecha_inicio, fecha_fin_planeada, fecha_fin_real, porcentaje_avance, imagen)

    @id = id.to_i
    @nombre = nombre.to_s
    @etapa = etapa.to_s
    @tipo = tipo.to_s
    @area_responsable = area_responsable.to_s
    @descripcion = descripcion.to_s
    @monto_contrato = monto_contrato.to_f
    @comuna = comuna.to_i
    @barrio = barrio.to_s
    @direccion = direccion.to_s
    @fecha_inicio = fecha_inicio.to_s
    @fecha_fin_planeada = fecha_fin_planeada.to_s
    @fecha_fin_real = fecha_fin_real.to_s
    @porcentaje_avance = porcentaje_avance.to_f
    @imagen = imagen.to_s
    etapas = ['En Ejecución', 'En Licitación', 'En Proyecto', 'Finalizada']
    #byebug
    raise InputException.new('La etapa ingresada no coincide con las opciones permitidas') unless etapas.include?(@etapa)
    raise InputException.new('El porcentaje de avance ingresado no está permitido') unless (@porcentaje_avance >= 0 && @porcentaje_avance <= 100)
    raise InputException.new('El monto ingresado no puede ser negativo') unless (@monto_contrato >= 0)
    raise InputException.new('El número de comuna debe estar entre 1 y 15') unless (@comuna >= 1 && @comuna <=15)
    raise InputException.new('La descripción no puede contener más de 2000 caracteres') unless (@descripcion.length <= 2000)
    #raise InputException.new('El formato de fecha ingresado no es válido') unless...
    #raise InputException.new('La fecha final planificada debe ser posterior a la fecha de inicio') unless @fecha_fin_planeada > @fecha_inicio
    #raise InputException.new('La fecha final real debe ser posterior a la fecha de inicio') unless @fecha_fin_real > @fecha_inicio
    # if @etapa == 'Finalizada' then 
    #   raise InputException.new('Toda obra FINALIZADA debe tener un porcentaje de avance del 100% y una fecha de finalización real acorde') unless (@porcentaje_avance == 100 && ! @fecha_fin_real.empty?)
    # end
    if @porcentaje_avance == 100 then 
      raise InputException.new('El 100% de avance sólo puede ser utilizado en obras FINALIZADAS') unless @etapa == 'Finalizada'
    end
    # if ! @fecha_fin_real.empty? then 
    #   raise InputException.new('La fecha de finalización real sólo está disponible para obras FINALIZADAS') unless @etapa == 'Finalizada'
    # end
  end

end