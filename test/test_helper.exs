ExUnit.start()

System.at_exit(fn _exit_code ->
  :ok = FDB.Network.stop()
end)
