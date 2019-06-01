class BaseContext
  include Lasershark::CommonContext

  attr_accessor :restaurant, :error

  def initialize(args={})
    update(args)
  end

  def modifiable
    self
  end

  def update(args)
    args.each do |k, v|
      begin
        send("#{k}=", v)
      rescue NoMethodError
      end
    end
  end

  def []=(key, value)
    update(key => value)
  end

  def [](key)
    send(key)
  end

  def to_h
    Hash[
      self.instance_variables.map do |var|
        [var.to_s.delete("@").to_sym, self.instance_variable_get(var)]
      end
    ]
  end
end