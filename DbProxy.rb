require 'rubygems'
require 'activerecord'

ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "test"
  )

class BlankSlate
  instance_methods.each { |m| undef_method m unless m =~ /^__/ }
end

class DbProxy < BlankSlate
  
  def initialize(db_id, object)
    @db_id, @object = db_id, object
  end
  
  def __db_id
    @db_id
  end
  
  def method_missing(*params)
    @object.send(*params)
  end
  
  def respond_to?(name)
    return true if name.to_s == '__db_id'
    @object.respond_to?(name)
  end
end

class Database
  
  def self.save!(obj)
    ar = get_ar_class(obj.class)
    if obj.respond_to?('__db_id'.to_sym) 
      db_obj = ar.find(obj.__db_id)
    else
      db_obj = ar.new     
    end
    db_obj.attributes.each_pair do |field, value|
      db_obj.send("#{field}=", obj.send(field)) if field != 'id' && obj.respond_to?(field)
    end
    db_obj.save!
  end
  
  def self.get_ar_class(type)
    if !self.const_defined?(type.to_s)
      self.class_eval "class #{type} < ActiveRecord::Base; end"
    end
    self.const_get(type.to_s)
  end

  def self.method_missing(name, *args)
    if /^find/ =~ name.to_s
      type = args.shift
      ar = get_ar_class(type)
      db_obj = ar.send(name, *args)
      return nil if db_obj.nil?
      return create_proxy(type, db_obj) if db_obj.class == ar
      return db_obj.map{ |o| create_proxy(type, o)} if db_obj.kind_of?(Array)
      db_obj
    else
      super
    end
  end
  
  def self.create_proxy(type, db_obj)
    obj = type.new
    db_obj.attributes.each_pair do |field, value|
      obj.send("#{field}=", value) if obj.respond_to?("#{field}=")
    end
    DbProxy.new(db_obj.id, obj)
  end  
end

class Table
  attr :name, true
end

class ARTable < ActiveRecord::Base
  set_table_name 'tables'
end

t = ARTable.find(1)
t.name = 'one'
t.save!
puts t.inspect
t.name = 'oneB'
t.save!
t = ARTable.find(1)
puts t.inspect


t = Database.find(Table, 1)
puts t.inspect
t.name = 'oneC'
puts t.inspect
Database.save!(t)
t = Database.find(Table, 1)
puts t.inspect

t = Table.new
t.name = 'three'
Database.save!(t)

t = Database.find_by_name(Table, 'three')
puts t.inspect

t = Database.find_all_by_name(Table, 'three')
puts t.inspect

