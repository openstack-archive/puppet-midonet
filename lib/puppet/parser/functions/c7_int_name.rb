require 'facter'

# Function to figure out old school to new school mappings
# Uses the biosdevname info to generate a mapping
module Puppet::Parser::Functions
  newfunction(:c7_int_name, :type => :rvalue) do |args|

    if args.length != 1
      raise(Puppet::ParseError, "No interface name passed to convert")
    end

    int_name = args[0]

    if Facter.value('osfamily') == 'Debian'
      os_majrelease = Facter.value('operatingsystemmajrelease')
      if(os_majrelease != '16.04')
        interfaces = {}
        kernel_devs=`/sbin/biosdevname -d`
        if ($?.to_i == 4)
          #Virtual Machine, so I give up
          return int_name
        end
        kernel_devs.split("\n").each do |dev_info|
          # Split the values
          name, value = dev_info.split(':', 2)

          # Stip the whitespace out
          name = name.sub(/^[\s\n\r]*/, '').sub(/[\s\n\r]*$/, '')
          value = value.sub(/^[\s\n\r]*/, '').sub(/[\s\n\r]*$/, '')

          # Grab the kernel names
          if name == 'Kernel name'
            # Figure out the old school mapping
            old_school=`/sbin/biosdevname --policy=all_ethN -i '#{value}'`
            interfaces[old_school.chomp] = value
          end
        end

          # Lookup
          if interfaces.has_key?(int_name)
            return interfaces[int_name]
          end

          # Default to what was passed
          return int_name
      end
      #nothing to do here..
      return int_name

      #Debian Ends Here
    end

    # Don't need any of this logic for 6
    Facter.loadfacts()
    os_majrelease = Facter.value('operatingsystemmajrelease')
    if os_majrelease != '7'
      return int_name
    end

    # Get the kernel names
    interfaces = {}
    kernel_devs=`/usr/sbin/biosdevname -d`
    kernel_devs.split("\n").each do |dev_info|
      # Split the values
      name, value = dev_info.split(':', 2)

      # Stip the whitespace out
      name = name.sub(/^[\s\n\r]*/, '').sub(/[\s\n\r]*$/, '')
      value = value.sub(/^[\s\n\r]*/, '').sub(/[\s\n\r]*$/, '')

      # Grab the kernel names
      if name == 'Kernel name'
        # Figure out the old school mapping
        old_school=`/usr/sbin/biosdevname --policy=all_ethN -i '#{value}'`
        interfaces[old_school.chomp] = value
      end
    end

    # Lookup
    if interfaces.has_key?(int_name)
      return interfaces[int_name]
    end

    # Default to what was passed
    return int_name
  end
end
