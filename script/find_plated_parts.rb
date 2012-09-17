# require File.expand_path('../../config/boot',  __FILE__)
# require Rails.root + '/config/environment'
require 'csv'

class FindPlatedParts
  
  def initialize
    @customer_names = ['Ge Power Electronics, Inc.', 'Lineage Power Installation Service']
    @start_date = Date.current.advance(:years => -1)
    @output_path = File.join(Rails.root, 'lineage_plated_parts.csv')
    @plating_subcontractors = ['SUBPRAL', 'SUBPREC', 'SUBPPSY', 'SUBUMF']
  end
  
  class ItemSummary 
    attr_accessor :item, :parent_item
    attr_accessor :release_date
    attr_accessor :operation
    def initialize(item, last_release_date)
      @item = item
      @release_date = last_release_date
    end
  end
  def add_item(part_number, revision, release_date)
    item = nil
    key = [job_item.part_number, job_item.revision]
    if (last_item_movement = @all_items[key]).nil?
      # New item
      item = M2m::Item.part_number(part_number).revision(revision).first          
      @all_items[key] = ItemSummary.new(item, job_item.release_date)
    elsif job_item.release_date > last_item_movement.release_date
      item = last_item_movement.item
      # Update last release date.
      last_item_movement.release_date = job_item.release_date
    end
    item
  end
  
  def get_exploded_lineage_parts
    @all_items = Hash.new
    customers = M2m::Customer.with_names(@customer_names).all
    M2m::Job.for_customers(customers).includes(:items).released_since(@start_date).each do |job|
      job.items.each do |job_item|
        add_item(job_item.part_number, job_item.revision, job_item.release_date)
      end
    end
    # Add BOM children to list.
    crawler = @all_items.dup
    crawler.each do |item, item_movement|
      bom_items = M2m::BomItem.with_parent_item(item).each do |child_item|
        add_item(child_item.part_number, child_item.revision, item_movement.release_date)
      end
    end
  end
  
  def determine_if_smt_plated
    @all_items.values.each do |item_summary|
      M2m::DefaultRouteOperation.item(item_summary.item).work_centers(@plating_subcontractors).each do |plating_operation|
        item_summary.operation = plating_operation
      end
    end
  end
  
  def run
    get_exploded_lineage_parts
    determine_if_smt_plated
    export_csv
    0
  end
  
  def export_csv
    CSV.open(@output_path, 'wb') do |csv|
      csv << ['Part Number', 'Revision', 'Description', 'Parent Part Number', 'Parent Revision', 'Parent Description', 'Last Transaction Date', 'Item Group', 'SMT Plated?', 'Operation Description', 'Subcontractor']
      @all_items.values.sort_by(&:part_number).each do |s|
        row = []
        row.push s.item.part_number
        row.push s.item.revision
        row.push s.item.description
        row.push s.parent_item.part_number
        row.push s.parent_item.revision
        row.push s.parent_item.description
        row.push s.release_date.try(:to_s, :database)
        row.push s.item.group_name
        row.push s.operation.present? ? 1 : 0
        row.push s.operation.operation_memo
        row.push s.operation.work_center.name
        csv << row
      end
    end
  end
end

exit FindPlatedParts.new.run
