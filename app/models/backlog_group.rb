require 'active_hash_methods'
class BacklogGroup < ActiveHash::Base
  self.data = [
    {:id => 1, :name => 'Not Paint', :cmethod => 'not_paint'},
    {:id => 2, :name => 'Paint Only', :cmethod => 'only_paint'}
  ]
  include ActiveHashMethods

  def filter_release?(release)
    case self.cmethod
    when :not_paint
      release.part_number.present? && release.part_number.downcase.starts_with?('paint')
    when :only_paint
      !release.part_number.present? || !release.part_number.downcase.starts_with?('paint')
    else
      false
    end
  end
end
