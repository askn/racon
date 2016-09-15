require "../model.cr"

module Racon::Field
  class Base
    @resource_class = uninitialized Racon::Resource.class
    property! resource_class

    def initialize
    end

    def field_type
      self.class.name.to_s.split("::").last.underscore
    end
  end

  class PrimaryKey < Base
  end

  class CreatedAt < Base
  end

  class UpdatedAt < Base
  end

  class Int32 < Base
  end

  class Int16 < Base
  end

  class Float32 < Base
  end

  class Float64 < Base
  end

  class String < Base
  end

  class Time < Base
  end

  class Bool < Base
  end

  class HasMany < Base
    # TODO
  end

  class BelongsTo < Base
    def self.with_options(args)
      b = self.new
      b.resource_class = args[:class_name].as(Racon::Resource.class)
      b
    end
  end
end
