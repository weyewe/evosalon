class ItemCategory < ActiveRecord::Base
  attr_accessible :name, :parent_id
  acts_as_nested_set
  
  has_many :items 
  
  validates_presence_of :name
  validate :unique_non_deleted_name , :parent_can_not_be_self, 
        :parent_id_must_present_if_not_base_category
  
  def unique_non_deleted_name
    current_object = self
     
     # claim.status_changed?
    if not current_object.name.nil? 
      if not current_object.persisted? and current_object.has_duplicate_entry?  
        errors.add(:name , "Sudah ada category  dengan nama sejenis" )  
      elsif current_object.persisted? and 
            current_object.name_changed?  and
            current_object.has_duplicate_entry?   
            # if duplicate entry is itself.. no error
            # else.. some error
            
          if current_object.duplicate_entries.count ==1  and 
              current_object.duplicate_entries.first.id == current_object.id 
          else
            errors.add(:name , "Sudah ada category  dengan nama sejenis" )  
          end 
      end
    end
  end
  
  def parent_can_not_be_self
    current_object = self
    if current_object.persisted? and current_object.id == current_object.parent_id 
      errors.add(:parent_id , "Tidak boleh sama dengan object sekarang" )  
    end
  end
  
  def parent_id_must_present_if_not_base_category
    current_object = self
    if not current_object.is_base_category? and current_object.parent_id.nil? 
      errors.add(:parent_id , "Tidak boleh kosong" )  
    end
  end
  
  def has_duplicate_entry?
    current_object  =  self  
    self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted   ', 
                {:name => current_object.name.downcase, :is_deleted => false  }]).count != 0  
  end
  
  def duplicate_entries
    current_object  =  self  
    return self.class.find(:all, :conditions => ['lower(name) = :name and is_deleted = :is_deleted  ', 
                {:name => current_object.name.downcase, :is_deleted => false }]) 
  end
  
  def self.create_by_employee(employee,  object_params ) 
    return nil if employee.nil? 
     
    new_object = self.new  
    new_object.creator_id = employee.id 
    new_object.name = object_params[:name]
    new_object.parent_id =  object_params[:parent_id]
    new_object.save 
     
    return new_object
  end
  
  def update_by_employee( employee, object_params )
    return nil if employee.nil? 
    
    self.creator_id = employee.id
    
    self.name = object_params[:name]
    self.parent_id = object_params[:parent_id]
    
    self.save
    return self 
  end
  
  def self.create_base_object( employee, object_params ) 
    return nil if employee.nil? 
    
    new_object = self.new 
    new_object.creator_id = employee.id 
    new_object.is_base_category = true 
    new_object.name = object_params[:name]
    
    new_object.save
    return new_object 
  end
  
  
  def self.all_selectable_objects
    objects  = self.where(:is_deleted => false ) .order("depth  ASC ")
    result = []
    objects.each do |object| 
      result << [ "#{object.name}" , 
                      object.id ]  
    end
    return result
  end
  
  def self.active_categories
    self.where(:is_deleted => false).order("created_at DESC")
  end
  
  def active_items
    self.items.where(:is_deleted => false ).order("created_at DESC")
  end
  
  def delete(employee)
    return nil if employee.nil? 
    
    parent = self.parent 
    if parent.nil?
      # can't be deleted from the base
      return nil
    end
    
    ActiveRecord::Base.transaction do
      self.is_deleted = true
      self.save

      self.class.where(:parent_id => self.id ).each do |sub_category|
        sub_category.parent_id = self.parent_id 
        sub_category.save 
      end
    end
    
    
    # self.items.each do |item|
    #   item.category_id = parent.id
    #   item.save 
    # end
    # what will happen to the item from this category? Go to the parent category 
  end
  
  
end
