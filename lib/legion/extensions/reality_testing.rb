# frozen_string_literal: true

require 'legion/extensions/reality_testing/version'
require 'legion/extensions/reality_testing/helpers/constants'
require 'legion/extensions/reality_testing/helpers/belief'
require 'legion/extensions/reality_testing/helpers/reality_engine'
require 'legion/extensions/reality_testing/runners/reality_testing'

module Legion
  module Extensions
    module RealityTesting
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
