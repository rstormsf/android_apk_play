module HomePage
	def self.click_nearby
		$wd.find_element(:name, "Nearby").click
  end

    def self.get_buttons
      buttons = []
      $wd.find_elements(:class, "Button").each  do |el|
        buttons.push el.text
      end
      buttons
    end

  #$wd.find_element(:id, "nearby")
  #$wd.find_element(:id, "aboutme")
  #$wd.find_element(:id, "bookmarks")
  #$wd.find_element(:id, "monocle")
  #$wd.find_element(:id, "check_ins")
  #$wd.find_element(:id, "friends")
  #$wd.find_element(:id, "talk")
  #$wd.find_element(:id, "recents")
  #$wd.find_element(:id, "deals")
end