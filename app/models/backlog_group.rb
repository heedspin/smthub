require 'active_hash_methods'
class BacklogGroup < ActiveHash::Base
  self.data = [
    {:id => 1, :name => 'Not Paint'},
    {:id => 2, :name => 'Paint Only'}
  ]
  include ActiveHashMethods

  def filter_release?(release)
    case self.cmethod.to_sym
    when :not_paint
      (pn = release.try(:item).try(:part_number)).present? && pn.downcase.starts_with?('paint')
    when :only_paint
      (pn = release.try(:item).try(:part_number)).present? && !pn.downcase.starts_with?('paint')
    else
      false
    end
  end
end
