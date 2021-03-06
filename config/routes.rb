GdriveFeed::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # @todo: use :only => [:show, :...] in resources to be able to override create method
  get 'monitored_resources/create_with/:gid', :to => 'monitored_resources#create_with', :as => 'create_with'

  get 'calculate_time_distance_to_previous', :to => 'resources#calculate_time_distance_to_previous', :as => 'calculate_time_distance_to_previous'
  get 'calculate_optimal_threshold', :to => 'resources#calculate_optimal_threshold', :as => 'calculate_optimal_threshold'
  get 'show_threshold', :to => 'resources#show_threshold', :as => 'show_threshold'

  get 'welcome', :to => 'management/management#welcome', :as => 'welcome'
  namespace :management do
    get 'new_researcher', :to => 'management#new_researcher'
    post 'create_researcher', :to => 'management#create_researcher'
    get 'grant_access', :to => 'management#grant_access'
  end

  resources :monitored_resources do
    collection do
      get 'grant_access'
    end

    member do
      get 'index_structure'
      get 'create_working_sessions'
      get 'calculate_all_working_sessions'
      get 'update_resources_metadata'
      get 'garbage_collection_mark'
      get 'garbage_collection_sweep'
    end

    resources :permissions do
      collection do
        get 'refresh'
      end
    end

    resources :document_groups do
      collection do
        get 'new_samedocument'
      end
    end

    resources :permission_groups
    resources :resources do
      member do
        get 'refresh_revisions'
        get 'download_revisions'
        get 'merged_revisions/:rev_id', :action => :merged_revisions, :as => 'merged_revisions'
        get 'show_svg'
      end
    end
    resources :reports do
      collection do
        get 'generate'
        get 'remove'
      end
    end
  end

  get 'reports/metareport', to: 'reports#metareport', :as => 'reports_metareport'
  get 'reports/statistics', to: 'reports#statistics', :as => 'reports_statistics'
  get 'reports/generate_metareport', to: 'reports#generate_metareport', :as => 'reports_generate_metareport'

  resources :monitored_periods
  resources :period_groups

  root :to => 'management/management#welcome'

  match "/delayed_job" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
