require "thor"

class EnviroblyBuilder::Cli::Main < Thor
  desc "version", "Show EnviroblyBuilder version"
  def version
    puts EnviroblyBuilder::VERSION
  end

  desc "services", "Manage services"
  subcommand "services", EnviroblyBuilder::Cli::Services
end
