require 'yaml/store'
class PersistenceManager

  def initialize
    @archivo_de_obras = YAML::Store.new 'obras.yml'
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_de_obras'] = [] if @archivo_de_obras['lista_de_obras'].nil?
    end
  end

  def agregar_obra(obra)
    raise ObrasException.new 'Ya existe una obra con ese ID' if lista_de_obras.include?(obra)
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_de_obras'] << obra
    end
  end

  def listar_obras
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_de_obras']
    end
  end

  def encontrar_obra(id_obra)
    obra_elegida = lista_de_obras.select{ |obra| obra.id == id_obra}
    obra_elegida.first
  end

  def eliminar_obra(id_obra)
    obra = encontrar_obra id_obra
    raise ObraException.new 'Obra no encontrada' if obra.nil?
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_de_obras'].delete_if {|obra| obra.id == id_obra}
    end
  end

  def modificar_obra(obra_nueva)
    obra_previa = encontrar_obra(obra_nueva.id)
    raise ObraException.new 'Obra no encontrada' if obra_previa.nil?
    @archivo_de_obras.transaction do
      @archivo_de_obras['lista_de_obras'].delete(obra_previa)
      @archivo_de_obras['lista_de_obras'] << obra_nueva
    end
  end

end