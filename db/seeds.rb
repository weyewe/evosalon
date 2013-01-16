role = {
  :system => {
    :administrator => true
  }
}

Role.create!(
:name        => ROLE_NAME[:admin],
:title       => 'Administrator',
:description => 'Role for administrator',
:the_role    => role.to_json
)
admin_role = Role.find_by_name ROLE_NAME[:admin]
first_role = Role.first

company = Company.create(:name => "Super metal", :address => "Tanggerang", :phone => "209834290840932")
admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

base_item_category =  ItemCategory.create :name => "Base Item" 
base_service_category =  ServiceCategory.create :name => "Base Service" 

item = Item.create_by_employee(  admin, {
  :name => "Item 1",
  :item_category_id => base_item_category.id  ,
  :recommended_selling_price => BigDecimal('150000')
}) 


service = Service.create_by_employee(  admin, {
  :name => "Item 1",
  :service_category_id => base_service_category.id  ,
  :recommended_selling_price => BigDecimal('180000')
})
