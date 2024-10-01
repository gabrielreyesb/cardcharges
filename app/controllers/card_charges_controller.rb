class CardChargesController < ApplicationController
    def home
    end

    def index
      selected_card_id = params[:card_id]

      @card_charges = CardCharge.all
      @card_charges = @card_charges.order(date: :asc)      

      #@cr_total = @card_charges.where(type_of_charge: "Cargo regular").sum(:amount)
      #@msi_total = @card_charges.where(type_of_charge: "Cargo MSI").sum(:amount)
      #@d_total = @card_charges.where(type_of_charge: "Depósito").sum(:amount)
    end
  
    def new
      @card_charge = CardCharge.new
    end

    def create 
      uploaded_file = params[:file]
      card_type = params[:card_type]

      case card_type
        when 'bbva_credit'
          process_bbva_credit(uploaded_file)
        when 'bbva_debit'
          process_bbva_debit(uploaded_file)
        when 'amex_credit'
          process_amex_credit(uploaded_file)
        else
          redirect_to card_charges_path, alert: 'Tipo de tarjeta no válido.'
          return
      end

      redirect_to card_charges_path, notice: 'Los cargos fueron importados correctamente.'
    end

    def update
      @card_charge = CardCharge.find(params[:id])
      CardCharge.transaction do
        if @card_charge.update(card_charge_params)
          redirect_to assign_categories_card_charges_path, notice: 'Category assigned successfully.'
        else
          render :assign_categories
        end
      end
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Charge not found or already categorized."
      redirect_to assign_categories_card_charges_path(month: params[:month])
    end

    def process_bbva_credit(uploaded_file)
      Rails.logger.error "Procesando archivo BBVA crédito"
      pattern = /\A\d+ DE \d+ .+\z/
      xlsx = Roo::Spreadsheet.open(uploaded_file.path)
      header_rows_to_skip = 0
      xlsx.each_row_streaming(offset: header_rows_to_skip) do |row| 
        type_of_charge = "Cargo regular"
        data_str = row[0].value
        date = Date.strptime(data_str, '%d/%m/%Y') rescue nil
        
        if date
          description = row[1].value 
          if description =~ pattern
            type_of_charge = "Cargo MSI"
          end
    
          charge = row[2].value.to_f
          deposit = row[3].value.to_f
    
          amount = charge != 0 && !charge.nil? ? charge : deposit
          type_of_charge = "Depósito" if amount == deposit
    
          card_charge = CardCharge.new(
            date: date, 
            description: description, 
            amount: amount,
            #type_of_charge: type_of_charge, 
            card_id: 1 
          )
    
          if card_charge.save
            puts "CardCharge created successfully!"
          else
            Rails.logger.error "Charge creation failed: #{card_charge.errors.full_messages.join(', ')}"
          end
        else
          Rails.logger.error "Error en fecha: #{data_str}" 
        end
      end
    end
    
    def process_bbva_debit(uploaded_file)
      # Implement the logic for processing Card B here
      # Similar to process_card_a, but tailored for Card B's specific format
    end

    def process_amex_credit(uploaded_file)
      pattern = /\A\d+ DE \d+ .+\z/
      xlsx = Roo::Spreadsheet.open(uploaded_file.path)
      header_rows_to_skip = 7
      xlsx.each_row_streaming(offset: header_rows_to_skip) do |row| 
        type_of_charge = "Cargo regular"
        date_str = row[0].value
        puts "Fecha en string: #{date_str}"
        date = Date.strptime(date_str, '%d %b %Y') rescue nil
        
        description = row[2].value 
        if description =~ pattern
          type_of_charge = "Cargo MSI"
        end

        amount = row[5].value.to_f
        type_of_charge = "Depósito" if amount < 0

        if date
          charge = CardCharge.create(
            date: date, 
            description: description, 
            amount: amount, 
            type_of_charge: type_of_charge, 
            card_id: 2
          ) 
          unless charge.valid?
            Rails.logger.error "Charge creation failed: #{charge.errors.full_messages.join(', ')}"
          end
        else
          Rails.logger.error "Error en fecha"
        end
      end
    end

    def assign_categories
      @selected_category_id = params[:category_id]
      @card_charges = CardCharge.all

      if @selected_category_id.present? && @selected_category_id != ""
        @card_charges = @card_charges.where(category_id: @selected_category_id)
      else
        @card_charges = @card_charges.where(category_id: nil)
      end

      @total_uncategorized_count = CardCharge.where(category_id: nil).count
      @selected_category = Category.find_by(id: @selected_category_id) if @selected_category_id.present?
    end

    def categorize_charges
      uncategorized_charges = CardCharge.where(category_id: nil)
      vendors = Vendor.all
    
      uncategorized_charges.each do |charge|
        vendors.each do |vendor|
          if vendor.name.downcase.in? charge.description.downcase
            charge.update(category_id: vendor.category_id) 
            break 
          end
        end
      end
      redirect_to root_path, notice: 'Uncategorized charges processed.' 
    end

    def monthly_report
      @card_charges = CardCharge.positive_amounts
      start_date = params[:start_date]
      end_date = params[:end_date]
      selected_category_id = params[:category_id]
      selected_card_id = params[:card_id]
    
      @card_charges = @card_charges.where(date: start_date..end_date) if start_date.present? && end_date.present?
      @card_charges = @card_charges.where(category_id: selected_category_id) if selected_category_id.present?
      @card_charges = @card_charges.where(card_id: selected_card_id) if selected_card_id.present? # Use @card_charges here
    
      @category_totals = @card_charges.joins('LEFT OUTER JOIN categories ON categories.id = card_charges.category_id')
                                      .group("categories.name")
                                      .sum(:amount)
    
      uncategorized_total = @card_charges.where(category_id: nil).sum(:amount)
      @category_totals["Sin categoría"] = uncategorized_total if uncategorized_total > 0
    
      @account_totals = @card_charges.group(:card_id)
                                      .pluck(:card_id, Arel.sql('SUM(amount) as total_amount'), Arel.sql('COUNT(*) as transaction_count'))
    
      @card_charges = @card_charges.order(date: :asc)
    end    

    private

    def card_charge_params
      params.require(:card_charge).permit(:category_id) 
    end
end
