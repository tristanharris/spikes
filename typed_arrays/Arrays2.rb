module FixnumArrayFunctions
  def total
    inject(0) do |sum,i|
	sum+i
    end
  end
end


class TypedArray < Array
  def self.new(a)
   if self == TypedArray
    type = a.first.class
    if a.any? { |obj| obj.class != type}
	raise 'Cannot make typed'
    else
      modname = (type.to_s+'Array')
      if Object.const_defined? modname
        mod = Object.const_get modname
        mod.new(a)
      end
    end
   else
    super
   end
  end

  def self.[](*params)
   if c=parentclass(*params)
    c
   else
    super
   end
  end

private
  def self.parentclass(*params)
   if self == TypedArray
    type = params.first.class
    if params.any? { |obj| obj.class != type}
	raise 'Cannot make typed'
    else
      modname = (type.to_s+'Array')
      if Object.const_defined? modname
        mod = Object.const_get modname
        mod.[](*params)
      end
    end
   else
    false
   end
  end
end
# class TypedArray
#   def self.method_missing(m,*p)
#     Array.send(m,*p)
#   end
# end

class FixnumArray < TypedArray
end

a=TypedArray[1,2,3]
puts a.inspect
puts a.class
b=TypedArray.new([1,4])
puts b.inspect
puts b.class
c=FixnumArray.new([1,2])
puts b.inspect
puts b.class