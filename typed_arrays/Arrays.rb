module FixnumArray
  def total
    inject(0) do |sum,i|
	sum+i
    end
  end
end


class Array
  def make_typed
    return if size == 0
    type = self.first.class
    if self.any? { |obj| obj.class != type}
	raise 'Cannot make typed'
    else
      modname = (type.to_s+'Array')
      if Object.const_defined? modname
        mod = Object.const_get modname
        self.extend mod
      end
    end
    self
  end
end

a=[1,2,3]
puts a.make_typed.total
puts a.total
a << 'bob'
puts a.total
