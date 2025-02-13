{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.time;

  timeZone = optionalString (cfg.timeZone != null) ''
    if [ -z $(systemsetup -listtimezones | grep "^ ${cfg.timeZone}$") ]; then
      echo "${cfg.timeZone} is not a valid timezone. The command 'listtimezones' will show a list of valid time zones." >&2
      false
    fi
    systemsetup -settimezone "${cfg.timeZone}" > /dev/null
  '';

in

{
  options = {

    time.timeZone = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "America/New_York";
      description = lib.mdDoc ''
        The time zone used when displaying times and dates. See <https://en.wikipedia.org/wiki/List_of_tz_database_time_zones>
        or run {command}`sudo systemsetup -listtimezones`
        for a comprehensive list of possible values for this setting.
      '';
    };

  };

  config = {

    system.activationScripts.time.text = mkIf (cfg.timeZone != null) ''
      # Set defaults
      echo "configuring time..." >&2

      ${timeZone}
    '';

  };
}
