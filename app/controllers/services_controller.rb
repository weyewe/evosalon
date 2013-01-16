class ServicesController < ApplicationController
  def new
    @objects = Service.active_objects
    @new_object = Service.new 
    
    respond_to do |format|
      format.html # show.html.erb 
      format.js 
    end
  end
  
  def create 
    @parent = ServiceCategory.find_by_id params[:service][:service_category_id]
    
    @object = Service.create_by_employee(  current_user,  params[:service])
    
    
    if @object.valid?
      @new_object=  Service.new
    else
      @new_object= @object
    end 
    
    respond_to do |format|
      format.html { render :file => 'services/new' }
      format.js 
    end
    
  end
  
  def search_service
    
    # verify the current_user 
    search_params = params[:q]
    
    @services = [] 
    service_query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    @services = Service.where{ (name =~ service_query)  & (is_deleted.eq false ) }.map{|x| {:name => x.name, :id => x.id }}
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @services }
    end 
  end
  
  def search_sales_order_service
    search_params = params[:q]
    @sales_order = SalesOrder.find_by_id params[:sales_order_id]
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    # @objects = Service.where(
    #              :id => @sales_order.service_id_list ,
    #              :is_deleted => false 
    #            ).map{|x| {:name => x.name, :id => x.id }}
    #          
    service_id_list =    @sales_order.service_id_list 
    @objects = Service.where{
          ( is_deleted.eq false) & 
          (id.in service_id_list ) & 
          (name =~ query) 
    }.map{|x| {:name => x.name, :id => x.id }} 
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @post }
      format.json { render :json => @objects }
    end
    
  end
  
  
  def edit
    @object = Service.find_by_id params[:id] 
  end
  
  def update
    @object = Service.find_by_id params[:id] 
    @object.update_by_employee( current_user, params[:service])
    @has_no_errors  = @object.errors.messages.length == 0
  end
  
  def destroy
    @object = Service.find_by_id params[:object_to_destroy_id]
    @object.delete(current_user)
  end
  
  
  
end
