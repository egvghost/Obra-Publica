require 'yaml/store'
class PersistenceManager

  def initialize
    @archivo_de_obras = YAML::Store.new 'obras.yml'
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_obras'] = [] if @archivo_de_obras['lista_obras'].nil?
    end
  end

  def crear_obra(obra)
    raise InputException.new 'Ya existe una obra con ese ID' if lista_obras.include?(obra)
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_obras'] << obra
    end
  end

  def lista_obras
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_obras']
    end
  end

  def encontrar_obra(id_obra)
    obra_elegida = lista_obras.select{ |obra| obra.id == id_obra}
    obra_elegida.first
  end

  def eliminar_obra(id_obra)
    obra = encontrar_obra id_obra
    raise InputException.new 'Obra no encontrada' if obra.nil?
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_obras'].delete_if {|obra| obra.id == id_obra}
    end
  end

  def modificar_obra(obra_nueva)
    obra_previa = encontrar_obra(obra_nueva.id)
    raise InputException.new 'Obra no encontrada' if obra_previa.nil?
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_obras'].delete(obra_previa)
      @archivo_de_obras['lista_obras'] << obra_nueva
    end
  end

end