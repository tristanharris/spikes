class TypedArrayException < Exception
end

class Array
  def to_typed
    return if size == 0
    type = self.first.class
    raise TypedArrayException.new('Cannot make typed array, cant do multi-dimension arrays') if type.kind_of? Array
    if self.any? { |obj| obj.class != type}
	raise TypedArrayException.new('Cannot make typed array, types of contents dont match')
    else
      modname = (type.to_s+'Array')
      mod = Object.const_get modname
      mod.new self
    end
  end
end

class Object
  class << self
    alias_method :const_missing_orig, :const_missing
    def const_missing(name)
      if (m=name.to_s.match(/^(.*)Array$/)) && Object.const_defined?(m[1])
        Object.class_eval "class #{name} < TypedArray; end"
	c=const_get name
	c.send :include, const_get(name.to_s+'Functions') if const_defined?(name.to_s+'Functions')
	c
      else
        begin
          const_missing_orig(name)
	rescue Exception => e
	  e.backtrace.shift
	  raise e
        end
      end
    end
  end
end

class TypedArray < Array
  def self.new(*params)
    s = super
    in_type *s
    s
  end

  def self.[](*params)
    in_type *params
    super
  end

  (self.public_instance_methods - Object.public_instance_methods).each do |m|
    class_eval(%{
      def #{m}(*params)
        s = super
        if s.kind_of? Array
          in_type *s
          if s.instance_of? Array
            s = self.class.new(s)
          end
        end
        s
        rescue TypedArrayException => e
	  e.backtrace.shift
	  e.backtrace.shift
	  msg = e.backtrace[1].split(':')
	  msg[2] = e.backtrace[0].split(':')[2]
	  e.backtrace[0] = msg.join(':')
	  raise e
      end
    })
  end

protected

  def self.in_type(*params)
    raise 'Cant create TypedArray object' if self == TypedArray
    type = Object.const_get self.to_s.sub(/Array$/,'')
    if params.all? { |obj| obj.kind_of? type}
	true
    else
      raise TypedArrayException.new('Invalid content for '+self.to_s)
    end
  end
  
  def in_type(*params)
    self.class.in_type(*params)
  end
end




module FixnumArrayFunctions
  def total
    inject(0) do |sum,i|
	sum+i
    end
  end
end


a=FixnumArray[1,2,3]
puts a.inspect
puts a.class
b=FixnumArray.new([1,4])
puts b.inspect
puts b.class

FixnumArray.new(5,6).inspect

c = b + [8,6]
puts c.inspect
puts c.class.inspect

puts c.include?(8)

puts c.delete_if{|o| o == 8}.inspect

puts [1,2,3].to_typed.inspect

puts c.total

s = ['a','b'].to_typed
puts s.class
puts s.inspect

#s << 5


# def hhh
# puts Bob
# s = ['a','b'].to_typed
# s << 5
# #3+'bob'
# end
# hhh

puts [1,2,3].to_typed.to_typed.class
