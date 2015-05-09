local nodewatcher = require('nodewatcher')

-- Configure node.
nodewatcher.configure({
  uuid = 'uuidhere',
  host = 'beta.wlan-si.net',
  port = 80,
})

-- Create a module for generic sensors.
sensors = nodewatcher.createModule('sensors.generic', 1)
-- Generate some sensor data.
data = {
  ['sensor-id-01'] = {
    name = 'Dummy Sensor',
    unit = 'U',
    value = 13.45,
  }
}
-- Push some data.
sensors:push(data)
