module GenymotionShell
  if ENV['PLATFORM'] == 'MAC'
	GENYMOTION_APP_PATH = ':/Applications/Genymotion Shell.app/Contents/MacOS'
  ANDROID_HOME = ':~/Repos/android/sdk'
  else
    GENYMOTION_APP_PATH = ':~/genymotion'
    ANDROID_HOME = ':~/android'
  end
	ENV['PATH'] += GENYMOTION_APP_PATH
  ENV['PATH'] += ANDROID_HOME + ANDROID_HOME + "/tools" + ANDROID_HOME + "/platform-tools"
  puts

	adb_device = %x{adb devices}
	@ip = adb_device.scan(/\d+\.\d+\.\d+\.\d+/).join("")
  %x{adb root}
	
		#//TODO: Pickup random location from array

	def self.genyshell command
		system("genyshell", "-r", @ip, "-c", command)
	end

	def self.activate_gps
		genyshell 'gps\ activate'
	end

	def self.get_latitude
		genyshell 'gps\ getlatitude'
	end	

	def self.get_longitude
		genyshell 'gps\ getlongitude'
	end	

	def self.set_latitude num
		genyshell "gps setlatitude #{num}"
	end

	def self.set_longitude num
		genyshell "gps setlongitude #{num}"
	end

	def self.ip
		@ip
  end

  def self.set_battery num
    genyshell "battery setmode manual"
    genyshell "battery setlevel #{num}"
  end

end