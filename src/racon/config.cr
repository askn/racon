module Racon
  class Config
    RESOURCES = [] of Resource.class

    def add_resource(obj)
      RESOURCES << obj
    end

    def resources
      RESOURCES
    end
  end
end
