require "httparty"
require "debug"

class EnviroblyBuilder::Cli::Builds < Thor
  THREAD_DONE_STATUSES = [nil, false]

  desc "pull", "Pull pending builds from provided URL authenticating with a HTTP bearer token and start them"
  method_options url: :string, token: :string
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
      debugger
    end

    puts "Work done. Exiting."
    # `shutdown 0`
  end

  private
    def authorization_headers
      { "Authorization" => options.token }
    end

    def parent_dir(image_tag)
      "/tmp/build-#{image_tag}"
    end

    def log_path(image_tag)
      File.join parent_dir(image_tag), "build.log"
    end

    def build_context_path(image_tag)
      File.join parent_dir(image_tag), "context"
    end

    def init_dirs_and_files(image_tag)
      build_context_path(image_tag).tap do |path|
        FileUtils.mkdir_p path
        puts "Created #{path}"
      end

      log_path(image_tag).tap do |path|
        FileUtils.touch path
        puts "Touched #{path}"
      end
    end

    def git_path
      File.join ENV["HOME"], "app.git"
    end

    def run_log_container(image_tag)
      name = "build-log-#{image_tag}"
      parts = [
        "docker",
        "run",
        "--name", name,
        "--detach",
        "--rm",
        "-v", "#{log_path(image_tag)}:/build.log",
        # "--log-opt", "awslogs-stream=Builder/#{image_tag}/build",
        "alpine",
        "tail -f /build.log"
      ]
      run_cmd_parts parts
    end

    def fetch_and_export_revision(build)
      parts = [
        "cd", git_path, "&&",
        "git", "fetch", "origin", build["revision"], "&&",
        "git", "archive", build["revision"], "|",
        "tar", "-x", "-C", build_context_path(build["image_tag"])
      ]
      run_cmd_parts parts
    end

    def run_cmd_parts(parts)
      cmd = parts.join " "
      puts cmd
      `#{cmd}`
    end

    def run_buildx_build_cmd(build)
      [
        "docker",
        "buildx",
        "build",
        build_context_path(image_tag)
      ]
    end

    def run_build(build)
      init_dirs_and_files build["image_tag"]

      run_log_container build["image_tag"]

      fetch_and_export_revision build

      # TODO: 3. Launch buildx build
      `echo "build: #{build["image_tag"]}" > #{log_path(build["image_tag"])}`

      # TODO: Cleanup
    end
end
