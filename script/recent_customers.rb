# rails r ./script/recent_customers.rb

require 'csv'

class RecentCustomers

  def initialize
    @output_path = File.join(Rails.root, "recent_customers.csv")
    @ordered_since = Date.current.beginning_of_year.advance(:years => -4)
  end

  def run
    @customers = {}
    @last_sales = {}
    M2m::SalesOrder.where(['somast.fstatus != ?', M2m::Status.cancelled.name]).ordered_since(@ordered_since).all(:include => :customer).each do |so|
      last_sale_date = @last_sales[so.customer_number]
      @customers[so.customer_number] = so.customer
      if last_sale_date.nil? or (last_sale_date < so.order_date)
        @last_sales[so.customer_number] = so.order_date
      end
    end
    puts "Writing #{@output_path}"
    CSV.open(@output_path, 'wb') do |csv|
      csv << ['Customer Name', 'Customer Number', 'Last Sale Date']
      @last_sales.each do |customer_number, last_sale|
        customer = @customers[customer_number]
        row = []
        row.push customer.company_name
        row.push customer_number
        row.push last_sale.to_s(:database)
        csv << row
      end
    end
    puts 'Done'
    0
  end

end

exit RecentCustomers.new.run
