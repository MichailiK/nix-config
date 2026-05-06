{lib, ...}: {
  options.mich.deployTool = lib.mkOption {
    type = lib.types.str;
    description = "The deploy tool used to eval/build this system";
    default = null;
  };
}
