require 'dbus'

ContainerID = `hostname`.chop
ServiceName = "io.docker.container"
ObjectName  = "/io/docker/container/#{ContainerID}"
IfaceName   = "io.docker.container.musicd"

p ServiceName, ObjectName, IfaceName

if ARGV[0] == 'server'
  bus = DBus.system_bus
  service = bus.request_service(ServiceName)

  class Test < DBus::Object
    # Create an interface.
    dbus_interface IfaceName do
      # Create a hello method in that interface.
      dbus_method :echo, "in voice:s, out ret:s" do |voice|
        puts "receive dbus: echo voice:#{voice}"
        [voice]
      end
    end
  end

  exported_obj = Test.new(ObjectName)
  service.export(exported_obj)

  loop = DBus::Main.new
  loop << bus
  loop.run

elsif ARGV[0] == 'client'
  cbus = DBus::SystemBus.instance
  ruby_service = cbus.service(ServiceName)
  obj = ruby_service.object(ObjectName)
  obj.introspect
  obj.default_iface = IfaceName
  response = obj.echo("hello")
  puts "response = #{response}"
end
