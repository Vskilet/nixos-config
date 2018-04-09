{config, pkgs, ...}:
{
  users.extraUsers.victor =
  { uid = 1111;
    isNormalUser = true;
    description = "Victor SENE";
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCaCc2qcQsd/VPDX1K97zJ/MjObWnTfRkA98xeNnVTeGoMmbf/fW1KszB+3IYCngCKLhliotHEXkqOK24vMLZ9ylVPTIPLNY5OWLFRQSOU/OykP8r4ikDWmMOwI+tqkoBknTUZdA1MN1JmkpE1cWL8vRJ7mnwl/p7xCMHV19N5+UdoIx3bFsm0CCUMIYSaIefoD3tpIzmgVqBkIH4FSmNwvXHwcXhhOTGqXbTJYC/GY2mI0AFvZI3T61ReV325ms7QRQlElXP8Rv8lpjr57VISNjKsPPNvifLjy10RjIS8iNioN6fJ0XBCfKOmm37VX86aFkAgWdpzxGojprOXnViwZEWSegnvKGx8FNx3gB54zF76e6koWS+qnYf9UTdogO6uXhXZb7AoMC9XD0/l6Egh8HzPWAUZtLx74zhB8ufoKmzqOp4YrCK8Cu4N/1UTFyPUoeSCZJdcE/9iqldym06mOi4rDV5cKCzs+Q0bVP8+x8SZ9ajYUH7l4sxjDHtHiyAYniWIxGPO5NazCfx7J+1GGzbtV0HuBwE/U20z+nBy+WZ4MowQTNb2E2uhq4OgQASx7uTKtyhnfT09A3toHZVerfH8ET8YEVnwdYMCA0GHYMOZ48h1ORdE+OLyqRlxjYTCB17Kc2icSL3iv8Yd66vQagy3A+C8OhZP1rdc15bEZnw== openpgp:0x28DF0235" ];
  };

}
