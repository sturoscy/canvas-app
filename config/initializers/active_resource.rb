module ActiveResource
  class Base

    # If the return response contains the word "data" we need to rename it
    # or else we could bump into the built-in type named Data
    alias_method :_find_or_create_resource_for, :find_or_create_resource_for
    def find_or_create_resource_for(name)
      name = "xdata" if name.to_s.downcase == "data"
      _find_or_create_resource_for(name)
    end
  end
end