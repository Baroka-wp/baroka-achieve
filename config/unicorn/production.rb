$worker  = 2
$timeout = 30
#Le nom de votre application (notez que l'actuel est inclus)
$app_dir = "/var/www/baroka-achive/current"
$listen  = File.expand_path 'tmp/sockets/unicorn.sock', $app_dir
$pid     = File.expand_path 'tmp/pids/unicorn.pid', $app_dir
$std_log = File.expand_path 'log/unicorn.log', $app_dir
# Défini pour que les paramètres définis ci-dessus soient appliqués
worker_processes  $worker
working_directory $app_dir
stderr_path $std_log
stdout_path $std_log
timeout $timeout
listen  $listen
pid $pid
preload_app true
before_fork do |undefined, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
  old_pid = "#{undefined.config[:pid]}.oldbin"
  if old_pid != undefined.pid
    begin
      Process.kill "QUIT", File.read(old_pid).to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end
after_fork do |undefined, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
