with import <nixpkgs> { };

mkShell {
  name = "dotnet-env";
  packages = [
    dotnet-sdk
    dotnet-runtime
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        ms-dotnettools.csharp
        ms-dotnettools.vscode-dotnet-runtime
      ];
    })
  ];
}
