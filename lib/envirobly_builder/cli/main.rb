class EnviroblyBuilder::Cli::Main < Thor
  desc "version", "Show EnviroblyBuilder version"
  def version
    puts EnviroblyBuilder::VERSION
  end

  desc "builds", "Manage builds"
  subcommand "builds", EnviroblyBuilder::Cli::Builds
end
