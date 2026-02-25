{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-basic
            latexmk
            collection-fontsrecommended
            geometry
            xcharter
            xstring
            xkeyval
            mweights
            fontaxes
            enumitem
            ;
        };
        buildTex = src: 
            pkgs.stdenvNoCC.mkDerivation {
              name = "${src}-tex-document";
              inherit src;

              buildInputs = with pkgs; [
                coreutils
                tex
              ];

              phases = [
                "unpackPhase"
                "buildPhase"
                "installPhase"
              ];

              buildPhase = ''
                runHook preBuild
                latexmk -interaction=nonstopmode -pdf main.tex
                runHook postBuild
              '';

              installPhase = ''
                runHook preInstall
                mkdir -p $out
                mkdir -p $out/src
                cp main.pdf $out/
                cp -r . $out/src
                runHook postInstall
              '';
        };
      in
      {
        formatter = pkgs.nixfmt-tree;

        packages = {
          spec = buildTex ./spec;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ ];
        };
      }
    );
}
