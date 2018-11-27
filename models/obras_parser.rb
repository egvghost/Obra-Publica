require 'smarter_csv'
require './models/obra_publica.rb'
require 'date'
require 'byebug'

class ObrasParser

  attr_accessor :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def parse
    raise 'Falló la importación de datos (archivo .csv no especificado).' unless @file_path
    raise 'Falló la importación de datos (el archivo .csv especificado no fue hallado).' unless File.file? @file_path

    @obras = []
    SmarterCSV.process(@file_path, col_sep: ';') do |row|
      row = row.first
      #Inicializo las fechas para evitar que se arrastre un valor del ciclo anterior del loop, 
      #en caso de no existir en el siguiente.
      @fecha_inicio = ""
      @fecha_fin_planeada = ""
      @fecha_fin_real = ""
      #byebug
      @fecha_inicio = Date.strptime(row[:fecha_inicio],"%d/%m/%Y") unless row[:fecha_inicio].nil?
      @fecha_fin_planeada = Date.strptime(row[:fecha_fin_planeada],"%d/%m/%Y") unless row[:fecha_fin_planeada].nil?
      @fecha_fin_real = Date.strptime(row[:fecha_fin_real],"%d/%m/%Y") unless row[:fecha_fin_real].nil?
     
      @obras << ObraPublica.new(row[:id], row[:nombre], row[:etapa], row[:tipo], row[:area_responsable], \
      row[:descripcion], row[:monto_contrato], row[:comuna], row[:barrio], row[:direccion], @fecha_inicio, \
      @fecha_fin_planeada, @fecha_fin_real, row[:porcentaje_avance], row[:imagen])
    end
    return @obras
  end
  
end