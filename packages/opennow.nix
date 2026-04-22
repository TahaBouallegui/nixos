{ appimageTools, fetchurl }:
let 
    pname = "OpenNOW";
    version = "0.3.6";

    src = fetchurl {
        url = "https://github.com/OpenCloudGaming/OpenNOW/releases/download/v${version}/${pname}-v${version}-linux-x86_64.AppImage";
        sha256 = "2+YDm5rJqEyCrHCehrJ2bzaCOJXYgBTGcE0NAEiWChI=";
    };
in
appimageTools.wrapType2 { inherit pname version src; }

