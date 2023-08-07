module EnviroblyBuilder
end

# require "active_support"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.eager_load
