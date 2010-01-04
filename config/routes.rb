ActionController::Routing::Routes.draw do |map|
  map.resources :users

  map.resource :session

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  map.resources :users
  map.resource :sessions

  map.connect 'admin', :controller => 'admin', :action => 'index'
  map.connect 'about', :controller => 'home', :action => 'about'

  map.connect 'track', :controller => 'track'
  map.connect 'track/add_from_search', :controller => 'track', :action => 'add_from_search', :format => 'html'
  map.connect 'track/add_from_upload', :controller => 'track', :action => 'add_from_upload', :format => 'html'
  map.connect 'track/add_from_last_fm', :controller => 'track', :action => 'add_from_last_fm', :format => 'html'
  map.connect 'track/edit', :controller => 'track', :action => 'edit', :format => 'html'
  map.connect 'track/delete', :controller => 'track', :action => 'delete', :format => 'html'
  map.connect 'track/latest', :controller => 'track', :action => 'latest'
  map.connect 'track/latest.xml', :controller => 'track', :action => 'latest', :format => 'xml'
  map.connect 'track/list_xml', :controller => 'track', :action => 'list_xml', :format => 'xml'
  map.connect 'track/lfm_list', :controller => 'track', :action => 'lfm_list'
  map.connect 'track/:permalink', :controller => 'track', :action => 'show', :format => 'html'
  
  map.signup '/claim', :controller => 'users', :action => 'claim' 
  map.signup '/signup', :controller => 'users', :action => 'new' 
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  map.auto_complete ':controller/:action', 
                    :requirements => { :action => /auto_complete_for_\S+/ },
                    :conditions => { :method => :get }

  map.root :controller => 'audiography', :action => 'index'
  map.connect ':identifier', :controller => 'audiography', :action => 'index'
  map.connect ':identifier.xml', :controller => 'audiography', :action => 'index', :format => 'xml'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end