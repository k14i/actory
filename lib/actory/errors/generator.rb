module Actory
module Errors

  class Generator

    def json(level: nil, message: nil, backtrace: nil)
      JSON.generate({:level => level.upcase, :message => message, :backtrace => backtrace})
    end

  end

end #Errors
end #Actory
