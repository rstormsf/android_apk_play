module Nearby
  def self.click_more_categories
    $wd.find_element(:name, "More Categories").click
  end

  def self.select_category_by_name name
    $wd.find_element(:name, name).click
  end

end