Evosalon::Application.routes.draw do
  devise_for :users
  root :to => 'home#index'
  resources :companies 
  match 'edit_main_company' => 'companies#edit_main_company', :as => :edit_main_company 
  match 'update_company/:id' => 'companies#update_company', :as => :update_company, :method => :post 
  
  resources :users
  resources :app_users
  
  resources :customers 
  resources :services
  resources :employees
  
  
  resources :item_categories do
    resources :items
  end
  resources :items 
  
  resources :items do
    resources :stock_migrations 
  end
  
  resources :service_categories do 
    resources :services 
  end
  resources :services 
  
  resources :stock_migrations
 
=begin
  USER SETTING
=end
  match 'edit_credential' => "passwords#edit_credential" , :as => :edit_credential
  match 'update_password' => "passwords#update" , :as => :update_password, :method => :put
 
##################################################
##################################################
######### APP_USER 
##################################################
##################################################
  match 'update_app_user/:user_id' => 'app_users#update_app_user', :as => :update_app_user , :method => :post 
  match 'delete_app_user' => 'app_users#delete_app_user', :as => :delete_app_user , :method => :post
end
