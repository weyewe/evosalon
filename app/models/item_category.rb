class ItemCategory < ActiveRecord::Base
  attr_accessible :name, :parent_id
  acts_as_nested_set
  
  has_many :items 
  
  validates_presence_of :name
  validate :unique_non_deleted_name , :parent_can_not_be_self
  
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
    if current_object.id == current_object.parent_id 
      errors.add(:parent_id , "Tidak boleh sama dengan object sekarang" )  
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
  
  def create_sub_object( category_params ) 
    new_category = self.class.create(:name => category_params[:name],
                              :parent_id => self.id ) 
    return new_category
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
    
    self.is_deleted = true
    self.save
    
    self.items.each do |item|
      item.category_id = parent.id
      item.save 
    end
    # what will happen to the item from this category? Go to the parent category 
  end
  
  
end
