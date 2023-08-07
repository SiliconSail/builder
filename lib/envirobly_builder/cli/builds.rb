require "httparty"
# require "debug"

class EnviroblyBuilder::Cli::Builds < Thor
  THREAD_DONE_STATUSES = [nil, false]

  desc "pull", "Pull pending builds from provided URL authenticating with a HTTP bearer token and start them"
  method_options url: :string, token: :string, log: :string
  def pull
    build_threads = []
    has_work = true

    while has_work
      response = HTTParty.get options.url, headers: authorization_headers

      response.each do |build|
        build_threads << Thread.new do
          run_build build
        end
      end

      has_work = build_threads.any? do |thread|
        !THREAD_DONE_STATUSES.include?(thread.status)
      end

      # TODO puts as an interval option
      sleep 5 if has_work
      puts "Sleeping..."
    end

    puts "Work done. Exiting."
    # `shutdown 0`
  end

  private
    def authorization_headers
      { "Authorization" => options.token }
    end

    def log_path

    end

    def run_build(build)
      `echo "build: #{build["image_tag"]}" > #{options.log}`
      # TODO:
    end
end
