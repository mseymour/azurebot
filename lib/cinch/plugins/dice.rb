# -*- coding: utf-8 -*-

require_relative 'dice/boneroller'

module Cinch
  module Plugins
    class Dice
      include Cinch::Plugin

      set plugin_name: "Dicebox", help: "Dicebox -- Uses standard dice notation.\nUsage: `<X#>YdZ<[+|-]A>` (Examples: `1d6`; `2d6-3`; `2#1d6`; `5#2d6+10`)"

      match /^(.+)/, use_prefix: false
      def execute(m, s)
      end
    end
  end
end
