/*
 * Copyright (c) 2011-2016 elementary LLC. (https://launchpad.net/switchboard-plug-power)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

namespace Power {
    public class PowerSupply {
        private Upower? upower;
        private UpowerDevice? upower_device;

        private const string dbus_upower_name = "org.freedesktop.UPower";
        private const string dbus_upower_root_path = "/org/freedesktop/UPower";
        private const uint LINE_POWER_TYPE = 1;
        private string dbus_upower_ac_path;
        
        public PowerSupply () {
            connect_dbus ();
        }


        public bool check_present () {
            bool return_value = false;

            try {
                upower_device.Refresh ();

                if (upower_device.Online && upower_device.PowerSupply) {
                    return_value = true;
                }
            } catch (Error e) {
                warning ("power supply:%s", e.message);
            }
            return return_value;
        }

        private void connect_dbus () {
            try{
                upower = Bus.get_proxy_sync (BusType.SYSTEM, dbus_upower_name, dbus_upower_root_path, DBusProxyFlags.NONE);
                get_upower_ac_device (upower);
            } catch (Error e) {
                critical ("power supply dbus connection to upower fault");
            }
            debug ("power supply path:%s  dbus connected", dbus_upower_ac_path);
        }

        private void get_upower_ac_device (Upower upow) {
            try {
                ObjectPath[] devs = upow.EnumerateDevices ();
                for (int i = 0; i < devs.length; i++) {
                    UpowerDevice dev = Bus.get_proxy_sync (BusType.SYSTEM, dbus_upower_name, devs[i], DBusProxyFlags.GET_INVALIDATED_PROPERTIES);
                    if (dev.Type == LINE_POWER_TYPE) {
                        upower_device = dev;
                        return;
                    }
                }
            } catch (Error e) {
                critical("power supply couldn't get upower devices");
            }
        }
    }
}
