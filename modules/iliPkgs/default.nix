{
  pkgs,
  iliPackages',
  ...
}: {
  _module.args.iliPkgs = iliPackages' pkgs;
}
