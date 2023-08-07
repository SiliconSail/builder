require "httparty"

class EnviroblyBuilder::Cli::Services < Thor
  desc "up", "Start services from provided URL authenticating with a HTTP bearer token"
  method_options url: :string, token: :string
  def up
    fetch_service_definition_file

    puts `docker compose -f #{service_definition_path} up --detach`
  end

  desc "down", "Stop services previously launched by up"
  def down
    puts `docker compose -f #{service_definition_path} down`
    FileUtils.rm service_definition_path
  end

  private
    def authorization_headers
      { "Authorization" => options.token }
    end

    def fetch_service_definition_file
      response = HTTParty.get options.url, headers: authorization_headers
      # content = JSON.pretty_generate(JSON.parse(response.body))

      if File.write(service_definition_path, response.body)
        puts "Service definition file saved to #{service_definition_path}"
      else
        raise StandardError, "Unable to save service definition file into #{service_definition_path}"
      end
    end

    def service_definition_path
      EnviroblyBuilder::Cli::SERVICE_DEFINITION_PATH
    end
end
