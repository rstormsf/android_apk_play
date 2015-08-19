$LOAD_PATH << '.'
$LOAD_PATH << './pages/.'

require 'rubygems'
require 'selenium-webdriver'
require 'require_all'
require_all 'pages'
require_relative 'genymotion'
require_relative 'selenium_helper'
require 'rspec'

include SeleniumHelper
include HomePage
include Nearby
include Selenium::WebDriver::DriverExtensions::HasTouchScreen

PATH_TO_APK = File.expand_path(File.dirname(__FILE__) + '/com.yelp.android_5.3.1.apk')
capabilities = {
	'device' => 'Selendroid',
	'browserName' => 'selendroid',
	'platform' => 'Mac',
	'version' => '4.2',
  'app' => PATH_TO_APK,
  'avdName' => 'selendroid',
  'emulator' => false,
  'aut' => 'com.yelp.android:5.3.1',
	'app-package' => 'com.yelp.android',
	'app-activity' => '.ui.activities.ActivityHome',
	'newCommandTimeout' => '0'
}

server_url = "http://0.0.0.0:4723/wd/hub"
selendroid_url = "http://0.0.0.0:4444/wd/hub"
gshell = GenymotionShell

if ENV['DEVICE'] == "GENY"
gshell.set_latitude "37.73"
gshell.set_longitude "-122.41"
gshell.set_battery "39"
end

$wd = Selenium::WebDriver.for(:remote, :desired_capabilities => capabilities, :url => selendroid_url)

#Sign Up for Yelp
$wd.find_element(:id, "email_address")
$wd.find_element(:id, "password").send_keys("password")
$wd.find_element(:id, "zip_code_edittext").send_keys("94102")
#swipe
zipcode = $wd.find_element(:id, "zip_code_text")
$wd.touch.flick(zipcode, 0, -100, :normal).perform
$wd.find_element(:id, "signup_button").click
$wd.find_element(:id, "button1").click

#NearBy
$wd.find_element(:link_text, "More Categories")
$wd.find_element(:partial_link_text, "Rest").click
#Swipe
#$wd.find_element(:id, "toggle") #MAP Button(ActionMenuItem)
#$wd.find_elements(:id, "search_rating")[4]
$wd.touch.flick(el, 0, -100, :normal).perform


$wd.manage.timeouts.implicit_wait = 99
#$wd.rotate :landscape
$wd.find_element(:name, "More options").click
$wd.find_element(:name, "Log In").click
$wd.find_element(:name, "Sign Up").click
$wd.find_element(:name, "Sign Up with Facebook").click
$wd.switch_to.window("WEBVIEW")
$wd.find_element(:name, "email").send_keys("email@email.com")
$wd.find_element(:name, "pass").send_keys("password")
$wd.find_element(:name, "login").click
#if first time login, just one click
if !(SeleniumHelper.isElementPresentByClass "_5iy9")
  $wd.find_element(:name, "__CONFIRM__").click
end
$wd.find_element(:name, "__CONFIRM__").click
sleep 5
$wd.switch_to.window("NATIVE_APP")
$wd.find_elements(:class, "EditText")[3].send_keys("password")
#zipcode
$wd.find_elements(:class, "EditText")[4].send_keys("94102")

birthdate =  $wd.find_element(:name, "Birthdate")
$wd.execute_script("mobile: scrollTo", :element => birthdate.ref)
sleep 3
#$wd.find_elements(:class, "EditText")[0].send_keys("username")
#$wd.find_elements(:class, "EditText")[1].send_keys("password")
$wd.find_element(:name, "Log In").text

HomePage.click_nearby
Nearby.click_more_categories
Nearby.select_category_by_name "Bars"


#swipeopt = {"touchCount" => "2", "startX"=> "0.95", "startY" => "0.3", "endX"=> "0.95", "endY"=> "0.7", "duration"=> "1.8"}



# @wd.quit
