# frozen_string_literal: true

require 'legion/extensions/reality_testing/helpers/constants'
require 'legion/extensions/reality_testing/helpers/belief'
require 'legion/extensions/reality_testing/helpers/reality_engine'
require 'legion/extensions/reality_testing/runners/reality_testing'

module Legion
  module Extensions
    module RealityTesting
      class Client
        include Runners::RealityTesting

        def initialize(**)
          @reality_engine = Helpers::RealityEngine.new
        end

        private

        attr_reader :reality_engine
      end
    end
  end
end
