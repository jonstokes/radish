class ReadCsv
  include Lasershark

  context_with(
    Class.new(BaseContext) do
      attr_accessor :file, :output
    end
  )
  delegate :file, :output, to: :context


  def call
    begin
      context.output = file.read.to_s.encode('UTF-8', {
        :invalid => :replace,
        :undef   => :replace,
        :replace => ''
      })
    rescue Exception => e
      context.fail!(error: e.message)
    end
  end
end