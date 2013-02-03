# coding: utf-8

module Cinch
  module Plugins
    class Dongs
      include Cinch::Plugin
      plugin "dongs"
      help "dongs -- My master tells you to go eat a bowl of dick."

      def dong
        dicklength = rand(20)+4
        dickcolor = rand(15+1)
        "![c#{dickcolor.to_s.rjust(2,"0")}]8#{"=" * dicklength}D".gsub(/!\[(.*?)\]/) { $1.tr('boruic', 2.chr + 15.chr + 18.chr + 31.chr + 29.chr + 3.chr) }
      end

      match /r([i]+)dgeracer$/, method: :ridgeracer
      def ridgeracer(m, i)
        m.reply "RIIII#{"II" * i.length}DGE RACER!"
      end

      match /w([i]+)deface$/, method: :wideface
      def wideface(m, i)
        m.reply i.length < 25 ? "('____#{"__" * i.length}'X)" : "WE MUST GO WIDER!"
      end

      match /dongs$/, method: :execute
      def execute(m)
        m.reply dong
      end

      match /dongs (\d+)$/, method: :execute_multiple
      def execute_multiple(m, d)
        if d.to_i == 37
          m.reply "37"
          sleep 1
          m.reply "My girlfriend sucked 37 dicks"
        elsif d.to_i > 5
          m.reply "More than 5 dongs is way too much, man.", true
        elsif d.to_i == 0
          m.reply "If you didn't want any dongs, then why did you ask?", true
        elsif d.to_i == -1
          m.reply "No infinite dongs for you.", true
        elsif d.to_i <= -2
          m.reply "...What?", true
        else
          d.to_i.times do
            m.reply dong
            sleep 0.10
          end
        end
      end

    end
  end
end