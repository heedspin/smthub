require 'active_hash_methods'
class BacklogGroup < ActiveHash::Base
  self.data = [
    {:id => 1, :name => 'Paint Only', :product_class_keys => ['PO'] },
    {:id => 2, :name => 'Contract', :product_class_keys => ['60'] },
    {:id => 3, :name => 'Catalog', :product_class_keys => ['70'] }
  ]
  include ActiveHashMethods

  def filter_release?(release)
    !self.product_class_keys.include?(release.item.item.product_class_key)
  end
end
