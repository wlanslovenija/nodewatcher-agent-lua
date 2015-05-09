--
-- A module for pushing sensor data to a nodewatcher installation via
-- the HTTP protocol using POST requests.
--

local nodewatcher
do
  -- Configuration.
  local cfg
  cfg = {
    uuid = nil,
    host = nil,
    port = nil,
  }

  --
  -- Updates configuration.
  --
  -- Parameters:
  --   config - A configuration dictionary containing the following fields:
  --     uuid - Node UUID.
  --     host - HTTP server host.
  --     port - HTTP server port.
  ---
  local configure = function(config)
    -- TODO: Error handling.
    cfg = config
  end

  --
  -- Performs push of sensor data to a nodewatcher server.
  --
  -- Parameters:
  --   data - JSON-serializable data to send.
  --
  local modulePush = function(self, data)
    -- Ensure that configuration is valid.
    if not cfg.uuid or not cfg.host or not cfg.port then
      print("ERROR: Attempted push without configuration.")
      return
    end

    -- Prepare data.
    payload = self:encode(data)
    if not payload then
      print("ERROR: Attempted push with invalid payload.")
      return
    end

    -- Create a client connection.
    client = net.createConnection(net.TCP, 0)
    -- Resolve hostname and connect to the server.
    client:dns(cfg.host, function(sock, ip)
      client:connect(cfg.port, ip)
      client:send("POST /push/http/" .. cfg.uuid .. " HTTP/1.1\r\n")
      client:send("Host: " .. cfg.host .. "\r\n")
      client:send("Connection: close\r\n")
      client:send("\r\n")
      -- Serialize payload to JSON.
      payload = cjson.encode(payload)
      client:send(payload)
      client:close()
      -- Delete the payload and client.
      payload = nil
      client = nil
    end)
  end

  --
  -- Encode module data.
  --
  -- Parameters:
  --   data - Data payload to encode.
  --
  local moduleEncode = function(self, data)
    local output = {
      [self.name] = {},
    }

    -- Include provided data.
    output[self.name] = data
    -- Include module metadata.
    output[self.name]._meta = {
      version = self.version,
    }

    return output
  end

  --
  -- Creates a new module.
  --
  -- Parameters:
  --   name - Module identifier.
  --   version - Module version.
  --
  local createModule = function(name, version)
    local mod = {
      -- Properties.
      name = name,
      version = version,

      -- Methods.
      encode = moduleEncode,
      push = modulePush,
    }

    return mod
  end

  -- Exported methods.
  nodewatcher = {
    configure = configure,
    createModule = createModule,
  }
end

return nodewatcher
