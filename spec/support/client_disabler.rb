Cangaroo::BaseJob.class_eval do
  def connection_request(*args)
    puts "CANGAROO CLIENT DISABLED FOR TESTS"
    {shipments: [], objects: []}
  end
end
