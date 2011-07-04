# -*- coding: UTF-8 -*-

require 'cinch'

class Fb2kControl
  include Cinch::Plugin
  plugin "foobar2000"
  help "fb (play|pause|pp|prev|next|rand|stop|np)"
  match /fb (play|pause|pp|prev|next|rand|stop|np)$/
  
	def initialize(*args)
		super;
    @Foobar2000_path = "\"C:\\Program Files (x86)\\foobar2000\\foobar2000.exe\"";
    @NP_file = "C:\\Users\\Mark Seymour\\etc\\now-playing.txt";
	end
  
  def execute(m, option)
    
    puts "\n\t@Foobar2000_path: #{@Foobar2000_path};\n\t@NP_File: #{@NP_file};\n\toption: #{option}\n\n";
    
    result = case option
      when "play"
        %x[#{@Foobar2000_path} /play];
        "Playing track..."
      when "pause"
        %x[#{@Foobar2000_path} /pause];
        "Pausing track..."
      when "pp"
        %x[#{@Foobar2000_path} /playpause];
        "Playing/pausing track..."
      when "prev"
        %x[#{@Foobar2000_path} /prev];
        "Playing previous track..."
      when "next"
        %x[#{@Foobar2000_path} /next];
        "Playing next track..."
      when "rand"
        %x[#{@Foobar2000_path} /rand];
        "Playing random track..."
      when "stop"
        %x[#{@Foobar2000_path} /stop];
        "Stopping playback..."
      when "np"
        np_str = "";
        File.open(@NP_file, 'r', external_encoding: Encoding::UTF_8) {|f| np_str = f.gets }
        m.reply(np_str.gsub(/^me /, ""));
        "Now playing sent -> #{np_str}"
    end
  
    puts result;

  end
end