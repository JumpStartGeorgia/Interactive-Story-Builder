##################################
##### SET THESE VARIABLES ########
##################################
root = "/home/bootstrap/Bootstrap-Starter/current" # path to application current folder
sock_name = "unicorn_Bootstrap-Starter" # must be unique name with no '.'
port_num = 8091 # must be a unique port number for this application
tout = 30 # time in seconds before process dies - need a long time for data uploads
##################################

working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

listen "/tmp/#{sock_name}.sock"
listen port_num, :tcp_nopush => true
worker_processes 2
timeout tout
