module  SeleniumHelper
  def isElementPresentByClass className
    begin
      raise Exception unless self.find_element(:class, className).displayed?
      return true
    rescue
      return false
    end
  end

  def isElementPresentById id
    begin
      raise Exception unless self.find_element(:id, id).displayed?
      return true
    rescue
      return false
    end
  end
end