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
    raise 'file_path not provided' unless @file_path
    raise 'File does not exist' unless File.file? @file_path

    obras = []
    SmarterCSV.process(@file_path) do |row|
      #byebug
      row = row.first
      fecha_inicio = Date.strptime(row[:fecha_inicio],"%d/%m/%y")
      fecha_fin_planeada = Date.strptime(row[:fecha_fin_planeada],"%d/%m/%y")
      fecha_fin_real = Date.strptime(row[:fecha_fin_real],"%d/%m/%y")
      monto_contrato = row[:monto_contrato].to_f
      byebug
      obras << ObraPublica.new(row[:id], row[:nombre], row[:etapa], row[:tipo], row[:area_responsable], 
        row[:descripcion], monto_contrato, row[:comuna], row[:barrio], row[:direccion], fecha_inicio, 
        fecha_fin_planeada, fecha_fin_real, row[:porcentaje_avance], row[:imagen])
    end
    return obras
  end
  
end