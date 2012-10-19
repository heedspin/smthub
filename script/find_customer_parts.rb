# rails r ./script/find_customer_parts.rb

require 'csv'

class FindCustomerParts

  def initialize
    @customer_numbers = [319, 1470, 272, 1511]
    @start_date = Date.current.advance(:years => -3)
    @output_path = File.join(Rails.root, "schneider_customer_parts.csv")
  end

  class ItemSummary
    attr_accessor :customer, :recent_sales_order, :item, :ancestories
    def initialize(customer, sales_order, item)
      @customer = customer
      @recent_sales_order = sales_order
      @item = item
      @ancestories = []
    end
  end
  def add_item(customer, sales_order, part_number, revision, parents)
    key = [part_number, revision]
    return false if self.all_items.member?(key)
    summary = self.all_items[key]
    if summary.nil?
      item = M2m::Item.part_number(part_number).revision(revision).first
      summary = self.all_items[key] = ItemSummary.new(customer, sales_order, item)
    elsif (sales_order.order_date < summary.recent_sales_order.order_date)
      summary.recent_sales_order = sales_order 
    end
    summary.ancestories.push(parents) if parents
    true
  end

  def all_items
    @all_items ||= Hash.new
  end

  def for_each_bom_child(part_number, revision, parents, &block)
    M2m::BomItem.with_parent(part_number, revision).each do |child_item|
      if yield(parents, child_item)
        for_each_bom_child(child_item.part_number, child_item.revision, parents + [child_item.part_number], &block)
      end
    end
  end

  def get_customer_parts(customer)
    M2m::SalesOrder.customer(customer).includes(:items).ordered_since(@start_date).each do |so|
      so.items.each do |so_item|
        if add_item(customer, so, so_item.part_number, so_item.revision, nil)
          for_each_bom_child(so_item.part_number, so_item.revision, [so_item.part_number]) do |parents, child_item|
            add_item(customer, so, child_item.part_number, child_item.revision, parents)
          end
        end
      end
    end
  end

  def run
    @customer_numbers.each do |customer_number|
      customer = M2m::Customer.with_customer_number(customer_number).first!  
      puts "Running: #{customer.name}"
      get_customer_parts(customer)
    end
    export_csv(@output_path)
    puts 'Done'
    0
  end

  def export_csv(output_path)
    puts "Writing #{output_path}"
    CSV.open(output_path, 'wb') do |csv|
      csv << ['Customer', 'Parent Parts', 'Part Number', 'Revision', 'Description', 'Item Group', 'On Hand', 'Committed', 'Recent SO Date', 'Recent Sales Order']
      self.all_items.values.sort_by { |s| [s.item.try(:part_number) || '', s.item.try(:revision) || ''] }.each do |s|
        row = []
        row.push s.customer.name
        row.push s.ancestories.map { |a| a.join(" => ") }.join("\n")
        row.push s.item.try(:part_number)
        row.push s.item.try(:revision)
        row.push s.item.try(:description).try(:strip)
        row.push s.item.try(:group_name).try(:strip)
        row.push s.item.quantity_on_hand
        row.push s.item.quantity_committed
        row.push s.recent_sales_order.order_date.to_s(:database)
        row.push s.recent_sales_order.order_number
        csv << row
      end
    end
  end
end

exit FindCustomerParts.new.run
