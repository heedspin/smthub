# rails r ./script/export_sold_by_product_class.rb

require 'csv'

class ExportSoldByProductClass

  def initialize
    @product_class = '70'
    @start_date = Date.current.beginning_of_year
    @output_path = File.join(Rails.root, "#{@start_date.year}_product_class_#{@product_class}.csv")
  end

  class ItemSummary
    attr_accessor :item, :quantity
    def initialize(item)
      @item = item
      @quantity = 0
    end
  end
  def get_item(part_number, revision)
    @get_items ||= {}
    key = [part_number, revision]
    @get_items[key] ||= M2m::Item.part_number(part_number).revision(revision).first
  end

  def add_item(item, quantity)
    summary = self.all_items[item]
    if summary.nil?
      summary = self.all_items[item] = ItemSummary.new(item)
    end
    summary.quantity += quantity
    true
  end

  def all_items
    @all_items ||= Hash.new
  end

  def get_bom_children(item)
    @bom_children ||= {}
    @bom_children[item] ||= M2m::BomItem.with_parent(item.part_number, item.revision).all
  end

  def add_item_and_children(item, quantity, &block)
    if item.drawing_number.present? 
      add_item(item, quantity)
    else
      bom_children = get_bom_children(item)
      # num_children_drawings = bom_children.count { |bc| get_item(bc.part_number, bc.revision).group_name == 'Finished Goods'}
      bom_children.each do |bom_child|
        bom_item = get_item(bom_child.part_number, bom_child.revision)
        add_item_and_children(bom_item, bom_child.quantity * quantity)
      end
    end
  end

  def run
    count = M2m::SalesOrderItem.product_class(@product_class).includes(:sales_order).ordered_since(@start_date).count
    puts "Processing #{count} sales order items"
    progress = 0
    M2m::SalesOrderItem.product_class(@product_class).includes(:sales_order).ordered_since(@start_date).each do |so_item|
      item = get_item(so_item.part_number, so_item.revision)
      add_item_and_children(item, so_item.quantity)
      putc '.'
      progress += 1
      if (progress % 20) == 0
        putc '.'
      end
      # if progress == 100
      #   break
      # end
    end
    export_csv(@output_path)
    puts 'Done'
    0
  end

  def export_csv(output_path)
    puts "Writing #{output_path}"
    CSV.open(output_path, 'wb') do |csv|
      csv << ['Part Number', 'Revision', 'Description', 'Item Group', 'Quantity', 'Standard Cost', 'Standard Price', 'Drawing']
      self.all_items.values.sort_by { |s| [s.item.try(:part_number) || '', s.item.try(:revision) || ''] }.each do |s|
        row = []
        row.push s.item.try(:part_number)
        row.push s.item.try(:revision)
        row.push s.item.try(:description).try(:strip)
        row.push s.item.try(:group_name).try(:strip)
        row.push s.quantity
        row.push s.item.try(:standard_cost)
        row.push s.item.try(:price)
        row.push s.item.fdrawno.strip
        csv << row
      end
    end
  end
end

exit ExportSoldByProductClass.new.run
