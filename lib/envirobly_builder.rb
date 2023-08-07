module EnviroblyBuilder
end

# require "active_support"
require "zeitwerk"
require "thor"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load
