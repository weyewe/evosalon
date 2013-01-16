class ServiceCategoriesController < ApplicationController
  def new
    @objects = ServiceCategory.active_objects 
    @new_service_category = ServiceCategory.new 
    @new_object = @new_service_category
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create
    base_service_category = ServiceCategory.find_by_id params[:service_category][:parent_id]
    
    # sleep 5
    
    @object = base_service_category.create_sub_object( params[:service_category] ) 
    if @object.valid?
      @new_object=  ServiceCategory.new
    else
      @new_object= @object
    end
    
  end
  
  def edit
    @object = ServiceCategory.find_by_id params[:id] 
  end
  
  def update 
    @object = ServiceCategory.find_by_id params[:id] 
    @object.update_attributes( params[:service_category])
    @has_no_errors  = @object.errors.messages.length == 0
  end
  
  def destroy
    @object = ServiceCategory.find_by_id params[:id]
    @object.delete(current_user )
  end
  
end
