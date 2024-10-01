Rails.application.routes.draw do
  resources :cards
  resources :vendors
  resources :categories
  root 'card_charges#home'

  resources :card_charges do
    collection do
      get 'assign_categories'
      get 'process_bbva_credit'
      get 'process_bbva_debit'
      get 'process_amex_credit'
    end
  end

  get 'categorize_charges', to: 'card_charges#categorize_charges'
  get 'monthly_report', to: 'card_charges#monthly_report', as: 'monthly_report_card_charges'

end