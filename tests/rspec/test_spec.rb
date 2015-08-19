require 'rubygems'
require 'selenium-webdriver'
require 'require_all'
require_all File.expand_path(File.dirname(__FILE__) + '../../../helpers')
require 'rspec'
require 'active_record'
require 'geokit'

include SeleniumHelper
include GenymotionShell
include Selenium::WebDriver::DriverExtensions::HasTouchScreen

class User < ActiveRecord::Base
  has_many :reviews
  has_many :ipinfos
  self.table_name = 'users'
end

class Review < ActiveRecord::Base
  belongs_to :user
  self.table_name = 'reviews'

end

class Ipinfo < ActiveRecord::Base
  belongs_to :user
  self.table_name = 'ipinfos'
end

class CurrentUser < ActiveRecord::Base
  self.table_name = 'current_id_user'
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

describe "Test", :type => :selenium do
  before(:all) do
    if ENV['ENVIRONMENT'] == 'LOCAL'
    @db = ActiveRecord::Base.establish_connection(
        adapter: 'postgresql',
    encoding: 'utf8',
    database: 'blog_development',
    pool: 5,
    timeout: 5000,
    username: 'some',
    password: '',
    )
    else
      @db = ActiveRecord::Base.establish_connection(
          'postgres://ID.compute-1.amazonaws.com:5432/creds'
      )
    end

    PATH_TO_APK = File.expand_path(File.dirname(__FILE__) + '../../' + 'signed_com.yelp.android_5.10.0.apk')
    capabilities = {
        'device' => 'Selendroid',
        'browserName' => 'selendroid',
        'platform' => 'Mac',
        'version' => '4.2',
        'app' => PATH_TO_APK,
        'avdName' => 'selendroid',
        'emulator' => false,
        'aut' => 'com.yelp.android:5.10.0',
        'app-package' => 'com.yelp.android',
        'app-activity' => '.ui.activities.ActivityHome',
        'newCommandTimeout' => '9000'
    }
    local_ip = Socket.ip_address_list.detect{ |intf| intf.ipv4_private?}.ip_address
    selendroid_url = "http://#{local_ip}:4444/wd/hub"

    @wd = Selenium::WebDriver.for(:remote, :desired_capabilities => capabilities, :url => selendroid_url)
  end

  after(:each) do
    @wd.quit
  end

  before(:each) do
    @current_user = CurrentUser.first
    id = @current_user.user_id
    @user = User.find_by(:id => id)
    @review = Review.find_by(:user_id => id)
    # @ipinfo = Ipinfo.find_by(:user_id => id)

    gshell = GenymotionShell

    location = Geokit::Geocoders::GoogleGeocoder.geocode("#{@user.zip}, California, United States", :bias => "us")
    location = location.all.first.endpoint([*0..360].sample,  [*(0.1..2.5).step(0.3).map { |x| x.round(2) }].sample)
    #/TODO geocoder gem
    if ENV['DEVICE'] == "GENY"
      gshell.set_latitude location.lat
      gshell.set_longitude location.lng
      gshell.set_battery "#{[*10..100].sample.to_s}"
    end

    @reviews = OpenStruct.new({
        :review => "Some Review",
        :type => "Restaurants",
        :content => "Completely awesome.

The food was mind blowing. Each dish has the perfect combination of flavors and textures.

If you want to test out some of the very best fancy dining in San Francisco this is the real deal.

The flambeed crepes were exceptional. Take one pound of sugar, one pound of butter, and one pound of cream and you get the most amazing dish. Each bite the skin on my arm tingled after the effects of an insane sugar rush.

Service and setting was also impeccable.

Prices are high so either 1) you are rich 2) someone else is paying or 3) you are asking someone to marry you "
                              })

  end

  def login
    @wd.find_element(:link_text, "Log In").click
    @wd.find_element(:id, "activity_login_editUsername").send_keys(@user.email)
    @wd.find_element(:id, "activity_login_editPassword").send_keys(@user.password)
    @wd.find_element(:id, "activity_login_btnLogin").click
    @wd.find_element(:link_text, "OK").click if @wd.isElementPresentById "alertTitle"
  end

  it "Sign up user", :sign_up do
    @wd.find_element(:id, "splash_button_top").click
    @wd.find_element(:id, "fb_sign_up").click
    sleep 2
    if(@wd.window_handles.size > 1)
      @wd.switch_to.window("WEBVIEW_0")
      sleep 2
    end
    @wd.find_element(:name, "email").send_keys(@user.email)
    @wd.find_element(:name, "pass").send_keys(@user.password)
    @wd.find_element(:name, "login").click
    # if account is locked?
    if(@wd.title == "Your Account Is Temporarily Locked")
      @wd.find_element(:css => "button").click
      sl_year = @wd.find_element(:id => "year")
      sl_month = @wd.find_element(:id => "month")
      sl_day = @wd.find_element(:id => "day")
      year = Selenium::WebDriver::Support::Select.new(sl_year)
      month = Selenium::WebDriver::Support::Select.new(sl_month)
      day = Selenium::WebDriver::Support::Select.new(sl_day)
      year.select_by(:text, @user.dob.year.to_s)
      month.select_by(:text, Date::MONTHNAMES[@user.dob.month].slice(0,3))
      day.select_by(:text, @user.dob.day.to_s)
      @wd.find_element(:css => "button[value='Continue']").click
      sleep 5

    end
    if (@wd.title == "Suspicious Login Attempt")
      @wd.find_element(:css => "button[value='This was me']").click
    end
    @wd.find_element(:name, "__CONFIRM__").click
    @wd.find_element(:name, "__CONFIRM__").click if @wd.isElementPresentByClass "_5iy9"
    @wd.switch_to.window("NATIVE_APP")
    sleep 1
    first_name = @wd.find_element(:id, "first_name").text
    last_name = @wd.find_element(:id, "last_name").text
    @user.update!(:first_name => first_name, :last_name => last_name)
    @wd.find_element(:id, "password").send_keys(@user.password)
    if @wd.find_element(:id, "zip_code_edittext").text.empty?
      @wd.find_element(:id, "zip_code_edittext").send_keys(@user.zip)
    else
      @user.update!(:zip => @wd.find_element(:id, "zip_code_edittext").text)
    end
    @wd.touch.scroll(100, 600).perform
    @wd.find_element(:id, "signup_button").click
    @user.update!({:has_yelp => true, :yelp_created => Date.today})
    @wd.find_element(:id => "next").click
    @wd.find_element(:id => "add").click
    @wd.find_element(:link_text=> "Yes").click
    @wd.find_element(:id => "alright_button").click
    save_location
    @db.connection.execute("UPDATE current_id_user SET user_id=#{@current_user.user_id + 1} where user_id=#{@current_user.user_id}")
    expect(@wd.find_element(:id => "nearby").text == "Nearby")
  end

  it "should Log in", :login do
    login
  end

  it "should post a review", :post_review do
    login
    @wd.find_element(:id, "nearby").click
    @wd.find_element(:partial_link_text, "More Cat").click
    @wd.find_element(:link_text, @reviews.type).click
    sleep 1
    @wd.touch.flick(@wd.find_elements(:id, "search_closes_in").last, 0, -250, :normal).perform
    sleep 1
    @wd.find_elements(:id, "search_image").last.click
    if @wd.find_element(:id, "bookmark").find_element(:id, "label").text == "Bookmark"
      @wd.find_element(:id, "bookmark").click
      @wd.find_element(:id, "write_review").click
      @wd.touch.down(580, 176).perform
      @wd.touch.down(580, 176).perform unless @wd.isElementPresentById "review_compose_edit_text"
      @wd.find_element(:id, "review_compose_edit_text").send_keys(@reviews.content)
      sleep 10
      @wd.find_element(:id, "add_review_next").click
      @wd.find_element(:id, "review_overview_facebook_share_button").click
      @wd.find_element(:id, "add_review_next").click
      if @wd.find_element(:id, "elite_prompt_title").text.include? "Way to go"
        @wd.find_element(:id, "elite_prompt_rootedbutton").click
      end
    end

  end

end


def get_ip_info
  uri = URI.parse("http://ipinfo.io/json")
  response = Net::HTTP.get_response(uri)
  json = OpenStruct.new(JSON.parse(response.body))
  json
end

def save_location
  info = get_ip_info
  loc = info.loc.split(",")
  ip_info = {:day => Date.today, :ip => info.ip, :lat => loc.first, :long => loc.last,
             :city => info.city, :zip => info.postal, :user_id => @user.id}
  @ipinfo = Ipinfo.new(ip_info)
  @ipinfo.save!
end
