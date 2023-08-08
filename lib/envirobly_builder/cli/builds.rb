require "httparty"

class EnviroblyBuilder::Cli::Builds < Thor
  THREAD_DONE_STATUSES = [nil, false]

  desc "pull", "Pull pending builds from provided URL authenticating with a HTTP bearer token and start them"
  method_options url: :string, token: :string, push: false, awslogs: false, debug: false
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

      # TODO sleep as an interval option
      sleep 5 if has_work
      puts "Sleeping..."

      if options.debug?
        require "debug"
        debugger
      end
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
        "--log-opt", "#{options.awslogs? ? "awslogs-stream" : "labels"}=Builder/#{image_tag}/build",
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

    def run_buildx_build(build)
      build_parts = [
        "time",
        "docker",
        "buildx",
        "build",
        "--progress=plain",
        options.push? ? "--push" : "--load",
        "-t", "#{build["repository_url"]}:#{build["image_tag"]}",
        "-f", File.join(build_context_path(build["image_tag"]), build["dockerfile_path"]),
        File.join(build_context_path(build["image_tag"]), build["build_context"])
      ]
      redirect_logs_parts = [
        "(#{build_parts.join " "})",
        "2>&1", "|", "tee", "-a", log_path(build["image_tag"])
      ]
      run_cmd_parts redirect_logs_parts
    end

    def run_build(build)
      init_dirs_and_files build["image_tag"]

      run_log_container build["image_tag"]

      fetch_and_export_revision build

      run_buildx_build build

      # TODO: Cleanup
    end
end
