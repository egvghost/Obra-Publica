require 'yaml/store'
class PersistenceManager

  def initialize
    @student_file = YAML::Store.new 'obras.yml'
    @student_file.transaction do
      @student_file['student_list'] = [] if @student_file['student_list'].nil?
    end
  end

  def add_student(student)
    raise StudentException.new 'Student already exists' if student_list.include?(student)
    @student_file.transaction do
      @student_file['student_list'] << student #como el push?
    end
  end

  def student_list
    @student_file.transaction do
      @student_file['student_list']
    end
  end

  def get_student(student_email)
    selected_students = student_list.select{ |student| student.email == student_email}
    selected_students.first #porque 'select' SIEMPRE devuelve un array
  end

  def delete_student(student_email)
    student = get_student student_email
    raise StudentException.new 'Student not found by email' if student.nil?
    @student_file.transaction do
      @student_file['student_list'].delete_if {|student| student.email == student_email}
    end
  end

  def edit_student(new_student)
    old_student = get_student(new_student.email)
    raise StudentException.new 'Student not found by email' if old_student.nil?
    @student_file.transaction do
      @student_file['student_list'].delete(old_student)
      @student_file['student_list'] << new_student
    end
  end

end