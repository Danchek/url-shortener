class BaseService
  def self.call(**args)
    service = self.new
    service.perform!(**args)
    service.result
  end

  def result
    @result ||= OpenStruct.new
  end
end
