# rails r ./script/find_plated_parts.rb

require 'csv'

class FindPlatedParts

  def initialize
    @customer_names = ['Ge Power Electronics, Inc.', 'Lineage Power Installation Service']
    @start_date = Date.current.advance(:years => -1)
    @output_path = File.join(Rails.root, 'all_plated_parts.csv')
    @plating_subcontractors = M2m::WorkCenter.work_center_ids(%w(SUBPRAL SUBPREC SUBPPSY SUBUMF SUBCRHP SUBINDU SUBHUDG SUBAMP SUBELRI SUBIPC SUBPPC SUBPMPC SUBSTRA SUBWMS)).all
    # @plating_subcontractors = M2m::WorkCenter.name_like(['PLATE', 'PLATING']).all
  end

  class ItemSummary
    attr_accessor :item, :ancestories
    attr_accessor :operation
    def initialize(item)
      @item = item
      @ancestories = []
    end
  end
  def add_item(part_number, revision, parents)
    key = [part_number, revision]
    return false if self.all_items.member?(key)
    summary = self.all_items[key]
    if summary.nil?
      item = M2m::Item.part_number(part_number).revision(revision).first
      summary = self.all_items[key] = ItemSummary.new(item)
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

  def get_exploded_lineage_parts
    customers = M2m::Customer.with_names(@customer_names).all
    # M2m::SalesOrder.customers(customers).includes(:items).ordered_since(@start_date).each do |so|
    M2m::SalesOrder.includes(:items).ordered_since(@start_date).each do |so|
      so.items.each do |so_item|
        if add_item(so_item.part_number, so_item.revision, nil)
          for_each_bom_child(so_item.part_number, so_item.revision, [so_item.part_number]) do |parents, child_item|
            add_item(child_item.part_number, child_item.revision, parents)
          end
        end
      end
    end
  end

  def determine_if_smt_plated
    self.all_items.values.each do |summary|
      if summary.item
        M2m::DefaultRouteOperation.item(summary.item).work_centers(@plating_subcontractors).each do |plating_operation|
          summary.operation = plating_operation
        end
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
      csv << ['Parent Parts', 'Part Number', 'Revision', 'Description', 'Item Group', 'SMT Plated?', 'Operation Description', 'Subcontractor']
      self.all_items.values.sort_by { |s| [s.item.try(:part_number) || '', s.item.try(:revision) || ''] }.each do |s|
        row = []
        row.push s.ancestories.map { |a| a.join(" => ") }.join("\n")
        row.push s.item.try(:part_number)
        row.push s.item.try(:revision)
        row.push s.item.try(:description).try(:strip)
        row.push s.item.try(:group_name).try(:strip)
        row.push s.operation.present? ? 1 : 0
        row.push s.operation.try(:operation_memo).try(:strip)
        row.push s.operation.try(:work_center).try(:name).try(:strip)
        csv << row
      end
    end
  end
end

exit FindPlatedParts.new.run
