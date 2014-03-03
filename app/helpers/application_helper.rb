module ApplicationHelper
  
  # General check_paging resource
  def check_paging(collection, collection_array, resource, context, is_new)
    if is_new
      @collection_hash = Hash.new { |hash, key| hash[key] = Array.new }
    end
    unless collection.empty?
      @page += 1
      collection = context.get(resource.to_sym, :page => @page, :per_page => 10, :access_token => ENV["API_TOKEN"])
      collection_array << collection
      self.check_paging(collection, collection_array, resource, context, false)
    else
      collection_array = collection_array.flatten!
      @collection_hash[context.id] = collection_array
      return collection_array, @collection_hash
    end
  end

  # Different paging check for users
  # Depricate this when there's time
  def check_user_paging(users, context)
    options = {}
    if params[:group_category_id] && params[:unassigned]
      @options[:unassigned] = params[:unassigned]
    end
    unless users.empty?
      @page += 1
      @options[:page]     = @page
      @options[:per_page] = @per_page
      
      users = context.get(:users, @options)
      @user_array << users
      self.check_user_paging(users, context)
    else
      @user_array.flatten!
    end
  end

=begin
    # If the above code stops working, use the ActiveResource::ResourceNotFound rescue code below
    @page += 1
    begin 
      collection = context.get(resource.to_sym, :page => @page, :per_page => @per_page, :access_token => ENV["API_TOKEN"])
    rescue ActiveResource::ResourceNotFound
      collection_array = collection_array.flatten!
      @collection_hash[context.id] = collection_array
      return collection_array, @collection_hash
    else
      collection_array << collection
      self.check_paging(collection, collection_array, resource, context, false)
    end

    # If the above code stops working, use the ActiveResource::ResourceNotFound rescue code below
    @page += 1
    begin 
      options[:page]          = @page
      options[:per_page]      = @per_page
      options[:access_token]  = ENV["API_TOKEN"]
      users = context.get(:users, options)
    rescue ActiveResource::ResourceNotFound
      @user_array.flatten!
    else
      @user_array << users
      self.check_user_paging(users, context)
    end
=end

end
